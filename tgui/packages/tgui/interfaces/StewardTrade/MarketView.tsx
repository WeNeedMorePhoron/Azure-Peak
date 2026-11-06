import { useState } from 'react';

import { useBackend } from '../../backend';
import {
  BUTTON_BG,
  badgeStyle,
  cardStyle,
  FONT_BODY,
  INK,
  INK_FAINT,
  INK_SOFT,
  inkButtonStyle,
  SEAL_AMBER,
  SEAL_BLUE,
  SEAL_GREEN,
  SEAL_RED,
  sectionHeaderStyle,
  subTabBarStyle,
  subTabStyle,
} from '../common/parchment';
import { groupByCategory } from './helpers';
import type { Data, MarketRegionOption, MarketRow } from './types';
import { formatMammon } from '../common/format';

type Side = 'import' | 'export';

type OnTrade = (req: { side: Side; regionId: string; goodId: string }) => void;

export const MarketView = (props: { data: Data; onTrade: OnTrade }) => {
  const { act } = useBackend<Data>();
  const { market_rows, good_catalog, autoexport_percentage } = props.data;
  const { onTrade } = props;

  const groups = groupByCategory(market_rows, good_catalog);
  const [activeCategory, setActiveCategory] = useState<string>(
    groups[0]?.category ?? '',
  );
  const [expanded, setExpanded] = useState<Set<string>>(new Set());

  const activeGroup =
    groups.find((g) => g.category === activeCategory) ?? groups[0];

  const toggleExpanded = (key: string) => {
    setExpanded((prev) => {
      const next = new Set(prev);
      if (next.has(key)) next.delete(key);
      else next.add(key);
      return next;
    });
  };

  return (
    <div>
      <div style={sectionHeaderStyle}>Market</div>
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'flex-end',
          gap: '12px',
          marginBottom: '6px',
          fontSize: FONT_BODY,
        }}
      >
        <div style={{ display: 'flex', gap: '6px' }}>
          <button
            type="button"
            style={inkButtonStyle({ color: SEAL_AMBER })}
            onClick={() => {
              const raw = window.prompt(
                "Surplus threshold (0-100%). Anything above this share of a good's limit is surplus. It is sold abroad each dawn, or when you press Export Surplus, up to what the best paying region still wants. Lower means more gets sold.",
                String(autoexport_percentage),
              );
              if (raw === null) return;
              const n = parseInt(raw, 10);
              if (Number.isNaN(n) || n < 0 || n > 100) return;
              act('set_autoexport_percentage', { pct: n });
            }}
          >
            Threshold {autoexport_percentage}%
          </button>
          <button
            type="button"
            style={inkButtonStyle({ color: SEAL_GREEN })}
            onClick={() => act('export_surplus_all')}
            title="Sell the surplus of every good to whichever region pays most, up to what it still wants today."
          >
            Export Surplus
          </button>
        </div>
      </div>
      {market_rows.length === 0 ? (
        <div style={{ textAlign: 'center', color: INK_SOFT }}>
          The stockpile isn&apos;t taking any goods right now.
        </div>
      ) : (
        <>
          <div style={subTabBarStyle}>
            {groups.map((g) => (
              <div
                key={g.category}
                style={subTabStyle(g.category === activeGroup?.category)}
                onClick={() => setActiveCategory(g.category)}
              >
                {g.label} ({g.rows.length})
              </div>
            ))}
          </div>
          {activeGroup && (
            <div style={{ marginTop: '6px', minHeight: '650px' }}>
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'flex-start',
                  gap: '6px',
                  flexWrap: 'wrap',
                  marginBottom: '6px',
                  fontSize: FONT_BODY,
                  color: INK_SOFT,
                }}
              >
                <span>Actions:</span>
                <button
                  type="button"
                  style={inkButtonStyle({ color: SEAL_GREEN })}
                  onClick={() =>
                    act('export_surplus_category', {
                      category: activeGroup.category,
                    })
                  }
                  title={`Sell ${activeGroup.label} surplus to whichever regions pay most.`}
                >
                  Export Surplus
                </button>
              </div>
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'flex-start',
                  gap: '6px',
                  flexWrap: 'wrap',
                  marginBottom: '6px',
                  fontSize: FONT_BODY,
                  color: INK_SOFT,
                }}
              >
                <span>Permissions:</span>
                <button
                  type="button"
                  style={inkButtonStyle({ color: SEAL_GREEN })}
                  onClick={() =>
                    act('allow_autoexport_category', {
                      category: activeGroup.category,
                    })
                  }
                  title={`Let the daily autoexport ship ${activeGroup.label} surplus abroad.`}
                >
                  Autoexport On
                </button>
                <button
                  type="button"
                  style={inkButtonStyle({ color: SEAL_RED })}
                  onClick={() =>
                    act('bar_autoexport_category', {
                      category: activeGroup.category,
                    })
                  }
                  title={`Stop autoexporting ${activeGroup.label} surplus.`}
                >
                  Autoexport Off
                </button>
              </div>
              {activeGroup.rows.map((row) => {
                const good = good_catalog[row.good_id];
                const name = good?.name ?? row.good_id;
                const importable = !!good?.importable;
                const eventColor =
                  row.event_tag === 'SHORTAGE'
                    ? SEAL_RED
                    : row.event_tag === 'GLUT'
                      ? SEAL_GREEN
                      : null;
                return (
                  <div key={row.good_id} style={cardStyle}>
                    <div style={{ marginBottom: '4px' }}>
                      <span style={{ fontWeight: 'bold' }}>{name}</span>
                      {eventColor && (
                        <span style={badgeStyle(eventColor)}>
                          {row.event_tag}
                        </span>
                      )}
                      <span
                        style={{
                          color: INK_FAINT,
                          marginLeft: '8px',
                          fontSize: FONT_BODY,
                        }}
                      >
                        Royal stock: {row.stock}/{row.stock_limit}
                      </span>
                    </div>
                    <SideBlock
                      side="import"
                      label="Buy"
                      color={SEAL_BLUE}
                      regions={row.import_regions}
                      unavailableLabel={
                        importable ? 'no producing region' : 'not importable'
                      }
                      goodId={row.good_id}
                      expanded={expanded.has(`${row.good_id}-import`)}
                      onToggle={() => toggleExpanded(`${row.good_id}-import`)}
                      onTrade={onTrade}
                    />
                    <SideBlock
                      side="export"
                      label="Sell"
                      color={SEAL_GREEN}
                      regions={row.export_regions}
                      unavailableLabel="no demanding region"
                      goodId={row.good_id}
                      expanded={expanded.has(`${row.good_id}-export`)}
                      onToggle={() => toggleExpanded(`${row.good_id}-export`)}
                      onTrade={onTrade}
                    />
                    <StockpileStrip row={row} />
                  </div>
                );
              })}
            </div>
          )}
        </>
      )}
    </div>
  );
};

const SideBlock = (props: {
  side: Side;
  label: string;
  color: string;
  regions: MarketRegionOption[];
  unavailableLabel: string;
  goodId: string;
  expanded: boolean;
  onToggle: () => void;
  onTrade: OnTrade;
}) => {
  const {
    side,
    label,
    color,
    regions,
    unavailableLabel,
    goodId,
    expanded,
    onToggle,
    onTrade,
  } = props;

  if (regions.length === 0) {
    return (
      <div style={sideLineStyle}>
        <span style={{ color: INK_FAINT, width: '34px' }}>{label}:</span>
        <span
          style={{ fontStyle: 'italic', color: INK_FAINT, marginLeft: '6px' }}
        >
          {unavailableLabel}
        </span>
      </div>
    );
  }

  const best = regions[0];
  const others = regions.slice(1);

  return (
    <>
      <div style={sideLineStyle}>
        <span style={{ color: INK_FAINT, width: '34px' }}>{label}:</span>
        <RegionRow
          side={side}
          color={color}
          region={best}
          goodId={goodId}
          isPrimary
          onTrade={onTrade}
        />
        <span
          style={{ color: INK_FAINT, fontSize: FONT_BODY, marginLeft: '8px' }}
        >
          ({regions.length} region{regions.length === 1 ? '' : 's'})
        </span>
        {others.length > 0 && (
          <button
            type="button"
            style={chevronStyle}
            onClick={onToggle}
            title={expanded ? 'Hide other regions' : 'Show other regions'}
          >
            {expanded ? '▲' : '▼'}
          </button>
        )}
      </div>
      {expanded &&
        others.map((r) => (
          <div
            key={r.region_id}
            style={{ ...sideLineStyle, marginLeft: '40px' }}
          >
            <RegionRow
              side={side}
              color={color}
              region={r}
              goodId={goodId}
              isPrimary={false}
              onTrade={onTrade}
            />
          </div>
        ))}
    </>
  );
};

const RegionRow = (props: {
  side: Side;
  color: string;
  region: MarketRegionOption;
  goodId: string;
  isPrimary: boolean;
  onTrade: OnTrade;
}) => {
  const { data } = useBackend<Data>();
  const { region_catalog } = data;
  const { side, color, region, goodId, onTrade } = props;
  const regionName = region_catalog[region.region_id]?.name ?? region.region_id;
  const saturated = region.capacity_today <= 0;
  const actionLabel = side === 'import' ? 'Import' : 'Export';
  const capacityColor = saturated
    ? INK_FAINT
    : side === 'import'
      ? SEAL_BLUE
      : SEAL_GREEN;
  return (
    <span
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: '4px',
        flexWrap: 'wrap',
      }}
    >
      <span>
        {regionName} @{' '}
        <span style={{ color: SEAL_AMBER }}>{formatMammon(region.unit_price)}m/u</span>
        {region.capacity_total > 0 && (
          <span
            title={
              side === 'import'
                ? `${region.capacity_today} of ${region.capacity_total} units left today at this price, up to ${region.batch_capacity} per shipment. Buying beyond that increases the price.`
                : `${region.capacity_today} of ${region.capacity_total} units of demand left today at this price, up to ${region.batch_capacity} per shipment. Selling beyond that drops the price.`
            }
            style={{
              color: capacityColor,
              marginLeft: '4px',
              fontSize: FONT_BODY,
            }}
          >
            [{region.capacity_today}/{region.capacity_total}]
          </span>
        )}
      </span>
      {!!region.is_blockaded && (
        <span style={badgeStyle(SEAL_RED)}>BLOCKADED</span>
      )}
      {saturated && (
        <span
          style={badgeStyle(INK_FAINT)}
          title={
            side === 'import'
              ? 'No supply left today. Further purchases cost more.'
              : 'No demand left today. Further sales pay less.'
          }
        >
          {side === 'import' ? 'NO SUPPLY' : 'NO DEMAND'}
        </span>
      )}
      <button
        type="button"
        style={inkButtonStyle({ color })}
        onClick={() =>
          onTrade({
            side,
            regionId: region.region_id,
            goodId,
          })
        }
      >
        {actionLabel}
      </button>
    </span>
  );
};

const sideLineStyle = {
  display: 'flex',
  flexWrap: 'wrap' as const,
  alignItems: 'center',
  fontSize: FONT_BODY,
  marginBottom: '3px',
};

const chevronStyle = {
  fontFamily: 'inherit',
  fontSize: FONT_BODY,
  padding: '1px 6px',
  marginLeft: '6px',
  border: `1px solid ${INK_FAINT}`,
  background: BUTTON_BG,
  color: INK_SOFT,
  cursor: 'pointer',
  borderRadius: '2px',
};

const stripStyle: React.CSSProperties = {
  display: 'flex',
  flexWrap: 'wrap',
  alignItems: 'center',
  gap: '8px',
  marginTop: '6px',
  paddingTop: '6px',
  borderTop: `1px dashed ${INK_FAINT}`,
  fontSize: FONT_BODY,
  color: INK_SOFT,
};

const stripCellStyle: React.CSSProperties = {
  display: 'inline-flex',
  alignItems: 'center',
  gap: '3px',
};

const stripValueStyle: React.CSSProperties = {
  color: INK,
  fontWeight: 'bold',
};

const flagPillStyle = (active: boolean): React.CSSProperties => ({
  fontSize: FONT_BODY,
  padding: '0 4px',
  border: `1px solid ${active ? SEAL_GREEN : INK_FAINT}`,
  color: active ? SEAL_GREEN : INK_FAINT,
  borderRadius: '2px',
  cursor: 'pointer',
  background: 'transparent',
  fontFamily: 'inherit',
});

const StockpileStrip = (props: { row: MarketRow }) => {
  const { act, data } = useBackend<Data>();
  const { row } = props;
  const goodId = row.good_id;
  const goodName = data.good_catalog[goodId]?.name ?? goodId;
  const cannotSell = !!row.never_supplied || row.stock <= 0;
  const cannotBuy = !!row.never_supplied || !!row.sold_out;
  const autoexportDisabled = !!row.autoexport_disabled;

  const sellToMarket = () => {
    if (cannotSell) return;
    const raw = window.prompt(
      `Sell how many ${goodName} to the market? Royal stock: ${row.stock}.`,
      '1',
    );
    if (raw === null) return;
    const n = parseInt(raw, 10);
    if (Number.isNaN(n) || n <= 0) return;
    act('sell_to_market', { good_id: goodId, quantity: n });
  };

  const buyFromMarket = () => {
    if (cannotBuy) return;
    const raw = window.prompt(
      `Buy how many ${goodName} from the market? The Treasury pays.`,
      '1',
    );
    if (raw === null) return;
    const n = parseInt(raw, 10);
    if (Number.isNaN(n) || n <= 0) return;
    act('buy_from_market', { good_id: goodId, quantity: n });
  };

  return (
    <div style={stripStyle}>
      <span style={stripCellStyle}>
        Market:{' '}
        <span style={stripValueStyle}>
          {row.market_label} {row.market_stock}/{row.market_target}
        </span>
      </span>
      <span style={stripCellStyle}>
        Buy:{' '}
        <span style={stripValueStyle}>{formatMammon(row.market_buy)}m</span>
      </span>
      <span style={stripCellStyle}>
        Sell:{' '}
        <span style={stripValueStyle}>{formatMammon(row.market_sell)}m</span>
      </span>
      <button
        type="button"
        style={inkButtonStyle({ color: SEAL_GREEN, disabled: cannotSell })}
        disabled={cannotSell}
        onClick={sellToMarket}
        title={
          row.never_supplied
            ? 'The market does not take this good.'
            : `Sell royal stock to the market. The first sells for ${formatMammon(row.market_sell)}m, and the price falls as the market fills.`
        }
      >
        Sell to Market
      </button>
      <button
        type="button"
        style={inkButtonStyle({ color: SEAL_BLUE, disabled: cannotBuy })}
        disabled={cannotBuy}
        onClick={buyFromMarket}
        title={
          row.never_supplied
            ? 'The market does not supply this good.'
            : row.sold_out
              ? 'The market is out of this good.'
              : `Buy from the market into royal stock, paid by the Treasury. The first costs ${formatMammon(row.market_buy)}m, and the price rises as the market empties.`
        }
      >
        Buy from Market
      </button>
      <span style={{ flex: 1 }} />
      <button
        type="button"
        style={flagPillStyle(!autoexportDisabled)}
        onClick={() => act('toggle_autoexport_disabled', { good_id: goodId })}
        title="Toggle Autoexport. When off, surplus stays in the stockpile."
      >
        {autoexportDisabled ? 'No-X' : 'X-OK'}
      </button>
    </div>
  );
};
