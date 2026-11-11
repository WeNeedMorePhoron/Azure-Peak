import type { CSSProperties } from 'react';
import { useEffect, useRef, useState } from 'react';

import { useBackend } from '../../backend';
import { formatMammon } from '../common/format';
import {
  badgeStyle,
  cardStyle,
  ellipsisCellStyle,
  FONT_BODY,
  INK,
  INK_FAINT,
  INK_SOFT,
  inkButtonStyle,
  inkInputStyle,
  PARCHMENT_SHADOW,
  SEAL_AMBER,
  SEAL_BLUE,
  SEAL_GREEN,
  SEAL_RED,
  sectionHeaderStyle,
} from '../common/parchment';
import { CATEGORY_ORDER } from './helpers';
import type {
  Caravan,
  CaravanLines,
  CaravanQuote,
  CaravanStopDraft,
  Data,
  RegionFlow,
  RegionRow,
} from './types';

type Draft = {
  caravan: string;
  caravanName: string;
  route: string;
  stops: CaravanStopDraft[];
};

type LineKind = 'buys' | 'sells' | 'tribute';

const QUOTE_DEBOUNCE_MS = 150;

let quoteStamp = Math.floor(Math.random() * 100000);

const asLines = (lines: CaravanLines | unknown[] | undefined): CaravanLines =>
  !lines || Array.isArray(lines) ? {} : { ...lines };

const sumLines = (stops: CaravanStopDraft[], kind: LineKind) =>
  stops.reduce(
    (total, stop) =>
      total + Object.values(stop[kind]).reduce((a, b) => a + b, 0),
    0,
  );

const fitTribute = (
  picks: CaravanLines,
  region: RegionRow | undefined,
  stockByGood: Record<string, number>,
): CaravanLines => {
  const fitted: CaravanLines = {};
  if (!region || region.tribute_claimed || region.blockaded) return fitted;
  let left = region.tribute_value;
  for (const [goodId, units] of Object.entries(picks)) {
    const price =
      region.produces.find((f) => f.good_id === goodId)?.tribute_price ?? 0;
    if (price <= 0 || !(goodId in stockByGood)) continue;
    const take = Math.min(units, Math.floor(left / price + 1e-9));
    if (take > 0) {
      fitted[goodId] = take;
      left -= take * price;
    }
  }
  return fitted;
};

const trimStop = (
  stop: CaravanStopDraft,
  region: RegionRow | undefined,
  stockByGood: Record<string, number>,
): CaravanStopDraft => {
  const buys: CaravanLines = {};
  for (const [goodId, units] of Object.entries(asLines(stop.buys))) {
    if (region?.produces.some((f) => f.good_id === goodId)) {
      buys[goodId] = units;
    }
  }
  const sells: CaravanLines = {};
  for (const [goodId, units] of Object.entries(asLines(stop.sells))) {
    const held = Math.min(units, stockByGood[goodId] ?? 0);
    if (held > 0 && region?.demands.some((f) => f.good_id === goodId)) {
      sells[goodId] = held;
    }
  }
  return {
    region_id: stop.region_id,
    buys,
    sells,
    tribute: fitTribute(asLines(stop.tribute), region, stockByGood),
  };
};

const sortFlows = (rows: RegionFlow[], data: Data) => {
  const rank = (goodId: string) => {
    const i = CATEGORY_ORDER.indexOf(
      data.good_catalog[goodId]?.category ?? 'misc',
    );
    return i < 0 ? CATEGORY_ORDER.length : i;
  };
  const name = (goodId: string) => data.good_catalog[goodId]?.name ?? goodId;
  return [...rows].sort(
    (a, b) =>
      rank(a.good_id) - rank(b.good_id) ||
      name(a.good_id).localeCompare(name(b.good_id)),
  );
};

const formatReturn = (seconds: number) => {
  const minutes = Math.ceil(seconds / 60);
  return minutes <= 1 ? 'a minute' : `${minutes} minutes`;
};

const chipStyle = (active: boolean, disabled = false): CSSProperties => ({
  ...inkButtonStyle({ color: active ? SEAL_BLUE : INK_SOFT, disabled }),
  fontWeight: active ? 'bold' : 'normal',
  ...(active ? { background: 'rgba(200,170,100,0.25)' } : {}),
});

const labelStyle: CSSProperties = {
  color: INK_SOFT,
  fontSize: FONT_BODY,
  fontWeight: 'bold',
  margin: '8px 0 4px',
};

const columnHeaderStyle: CSSProperties = {
  color: INK_SOFT,
  fontWeight: 'bold',
  borderBottom: `1px solid ${INK_FAINT}`,
  paddingBottom: '2px',
  marginBottom: '4px',
  fontSize: FONT_BODY,
};

const emptyStyle: CSSProperties = {
  fontStyle: 'italic',
  color: INK_FAINT,
  fontSize: FONT_BODY,
};

export const CaravansView = (props: { data: Data }) => {
  const { data } = props;
  const { act } = useBackend<Data>();
  const [draft, setDraft] = useState<Draft | null>(null);

  const regionById: Record<string, RegionRow> = {};
  for (const row of data.region_rows || []) {
    regionById[row.region_id] = row;
  }
  const stockByGood: Record<string, number> = {};
  for (const row of data.market_rows || []) {
    stockByGood[row.good_id] = row.stock;
  }

  useEffect(() => {
    if (!draft) return;
    const caravan = data.caravans.find((c) => c.ref === draft.caravan);
    if (!caravan || caravan.on_road) setDraft(null);
  }, [data.caravans, draft]);

  const closePlanner = () => {
    act('caravan_quote_close');
    setDraft(null);
  };

  const planTrip = (caravan: Caravan) =>
    setDraft({
      caravan: caravan.ref,
      caravanName: caravan.name,
      route: '',
      stops: [],
    });

  const planAgain = (caravan: Caravan) => {
    const last = caravan.last_trip;
    if (!last) return;
    const stops = Array.isArray(last.stops) ? last.stops : [];
    setDraft({
      caravan: caravan.ref,
      caravanName: caravan.name,
      route: last.route,
      stops: stops.map((stop) =>
        trimStop(stop, regionById[stop.region_id], stockByGood),
      ),
    });
  };

  return (
    <div>
      <div style={sectionHeaderStyle}>Caravans</div>
      {data.caravans.map((caravan) => (
        <CaravanCard
          key={caravan.ref}
          caravan={caravan}
          planning={draft?.caravan === caravan.ref}
          onPlan={() => planTrip(caravan)}
          onPlanAgain={() => planAgain(caravan)}
        />
      ))}
      {draft && (
        <TripPlanner
          data={data}
          draft={draft}
          setDraft={setDraft}
          regionById={regionById}
          stockByGood={stockByGood}
          onClose={closePlanner}
        />
      )}
    </div>
  );
};

const CaravanCard = (props: {
  caravan: Caravan;
  planning: boolean;
  onPlan: () => void;
  onPlanAgain: () => void;
}) => {
  const { caravan, planning, onPlan, onPlanAgain } = props;
  const onRoad = !!caravan.on_road;
  const accent = onRoad ? SEAL_AMBER : planning ? SEAL_BLUE : PARCHMENT_SHADOW;
  return (
    <div style={{ ...cardStyle, borderLeft: `4px solid ${accent}` }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
        <span style={{ fontWeight: 'bold', fontSize: FONT_BODY }}>
          {caravan.name}
        </span>
        <span style={{ color: INK_SOFT, fontSize: FONT_BODY }}>
          {onRoad
            ? `On the road to ${caravan.region_names}. Back in ${formatReturn(caravan.returns_in ?? 0)}.`
            : 'At home.'}
        </span>
        {!onRoad && (
          <span style={{ marginLeft: 'auto', display: 'flex', gap: '6px' }}>
            {!!caravan.last_trip && (
              <button
                type="button"
                style={inkButtonStyle({ color: SEAL_GREEN })}
                title="Load this caravan's last trip, trimmed to today's royal stock and tribute."
                onClick={onPlanAgain}
              >
                Plan again
              </button>
            )}
            <button
              type="button"
              style={inkButtonStyle({ color: SEAL_BLUE })}
              onClick={onPlan}
            >
              Plan a trip
            </button>
          </span>
        )}
      </div>
      {onRoad && (
        <div style={{ color: INK_FAINT, fontSize: FONT_BODY, marginTop: '2px' }}>
          {caravan.route_name} &middot; {caravan.sell_units} goods out for{' '}
          {formatMammon(caravan.sell_revenue)}m &middot; {caravan.buy_units}{' '}
          goods home for {formatMammon(caravan.buy_cost)}m
          {caravan.has_tribute ? ' · collecting tribute' : ''}
          {caravan.booked_by ? ` · sent by ${caravan.booked_by}` : ''}
        </div>
      )}
    </div>
  );
};

const TripPlanner = (props: {
  data: Data;
  draft: Draft;
  setDraft: (draft: Draft | null) => void;
  regionById: Record<string, RegionRow>;
  stockByGood: Record<string, number>;
  onClose: () => void;
}) => {
  const { data, draft, setDraft, regionById, stockByGood, onClose } = props;
  const { act } = useBackend<Data>();
  const stampRef = useRef(0);
  const lastQuoteRef = useRef<CaravanQuote | null>(null);

  useEffect(() => {
    quoteStamp += 1;
    const stamp = quoteStamp;
    stampRef.current = stamp;
    const timer = window.setTimeout(() => {
      act('caravan_quote', {
        stamp,
        route: draft.route,
        orders: draft.stops,
      });
    }, QUOTE_DEBOUNCE_MS);
    return () => window.clearTimeout(timer);
  }, [draft, data.day, act]);

  const incoming = data.caravan_quote;
  const fresh = !!incoming && incoming.stamp === stampRef.current;
  if (fresh) lastQuoteRef.current = incoming;
  const quote = lastQuoteRef.current;

  const route = data.caravan_routes.find((r) => r.id === draft.route);
  const regionName = (regionId: string) =>
    data.region_catalog[regionId]?.name ?? regionId;

  const toggleRegion = (regionId: string) => {
    if (draft.stops.some((s) => s.region_id === regionId)) {
      setDraft({
        ...draft,
        stops: draft.stops.filter((s) => s.region_id !== regionId),
      });
      return;
    }
    const region = regionById[regionId];
    setDraft({
      ...draft,
      stops: [
        ...draft.stops,
        {
          region_id: regionId,
          buys: {},
          sells: {},
          tribute: fitTribute(
            asLines(data.tribute_picks?.[regionId]),
            region,
            stockByGood,
          ),
        },
      ],
    });
  };

  const updateStop = (next: CaravanStopDraft) =>
    setDraft({
      ...draft,
      stops: draft.stops.map((s) =>
        s.region_id === next.region_id ? next : s,
      ),
    });

  const outUnits = sumLines(draft.stops, 'sells');
  const homeUnits = sumLines(draft.stops, 'buys');
  const canSend = fresh && !!quote?.ok;
  const sendTitle = !fresh ? 'Pricing...' : quote?.ok ? '' : quote?.error;

  return (
    <div style={{ ...cardStyle, borderLeft: `4px solid ${SEAL_BLUE}` }}>
      <div style={{ display: 'flex', alignItems: 'center' }}>
        <span style={{ fontWeight: 'bold', fontSize: FONT_BODY }}>
          Planning {draft.caravanName}
        </span>
      </div>

      <div style={labelStyle}>Route</div>
      <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap' }}>
        {data.caravan_routes.map((r) => (
          <button
            key={r.id}
            type="button"
            style={chipStyle(draft.route === r.id)}
            onClick={() =>
              setDraft({
                ...draft,
                route: r.id,
                stops: draft.route === r.id ? draft.stops : [],
              })
            }
          >
            {r.name} &middot; {r.trip_minutes} min
          </button>
        ))}
      </div>

      {route && (
        <>
          <div style={labelStyle}>
            Regions (up to {data.caravan_stops_max})
          </div>
          {route.subroutes.map((sub) => (
            <div
              key={sub.name}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                flexWrap: 'wrap',
                marginBottom: '4px',
              }}
            >
              <span
                style={{ color: INK_FAINT, fontSize: FONT_BODY, width: '150px' }}
              >
                {sub.name}
              </span>
              {!sub.region_ids.length && <span style={emptyStyle}>none</span>}
              {sub.region_ids.map((regionId) => {
                const region = regionById[regionId];
                const chosen = draft.stops.some(
                  (s) => s.region_id === regionId,
                );
                const full =
                  !chosen && draft.stops.length >= data.caravan_stops_max;
                const raided = !!region?.blockaded;
                const disabled = (raided && !chosen) || full;
                return (
                  <button
                    key={regionId}
                    type="button"
                    disabled={disabled}
                    title={
                      raided
                        ? 'Raiders are blocking the road.'
                        : full
                          ? `A caravan trades with at most ${data.caravan_stops_max} regions.`
                          : ''
                    }
                    style={chipStyle(chosen, disabled)}
                    onClick={() => toggleRegion(regionId)}
                  >
                    {regionName(regionId)}
                    {raided && (
                      <span style={badgeStyle(SEAL_RED)}>BLOCKADED</span>
                    )}
                  </button>
                );
              })}
            </div>
          ))}
        </>
      )}

      {draft.stops.map((stop) => (
        <StopPanel
          key={stop.region_id}
          data={data}
          stop={stop}
          region={regionById[stop.region_id]}
          regionName={regionName(stop.region_id)}
          stockByGood={stockByGood}
          quoteStop={
            fresh && quote?.ok
              ? quote.stops.find((s) => s.region_id === stop.region_id)
              : undefined
          }
          onChange={updateStop}
        />
      ))}

      <div style={{ display: 'flex', gap: '16px', marginTop: '8px' }}>
        <CapacityBar
          label="Goods out"
          used={outUnits}
          capacity={data.caravan_capacity}
          color={SEAL_GREEN}
        />
        <CapacityBar
          label="Goods home"
          used={homeUnits}
          capacity={data.caravan_capacity}
          color={SEAL_BLUE}
        />
      </div>

      <div
        style={{
          fontSize: FONT_BODY,
          marginTop: '8px',
          minHeight: '20px',
          opacity: fresh ? 1 : 0.6,
        }}
      >
        {!quote ? (
          <span style={{ color: INK_FAINT }}>Pricing...</span>
        ) : quote.ok ? (
          <span style={{ color: INK_SOFT }}>
            Cost now{' '}
            <b style={{ color: SEAL_AMBER }}>
              {formatMammon(quote.buy_cost)}m
            </b>{' '}
            &middot; Sales paid on return{' '}
            <b style={{ color: SEAL_GREEN }}>
              {formatMammon(quote.sell_revenue)}m
            </b>{' '}
            &middot; Treasury after departure{' '}
            <b style={{ color: INK }}>
              {formatMammon(data.treasury - quote.buy_cost)}m
            </b>
            {route ? ` · Back in ${route.trip_minutes} minutes` : ''}
          </span>
        ) : (
          <span style={{ color: SEAL_RED }}>{quote.error}</span>
        )}
      </div>

      <div
        style={{
          display: 'flex',
          justifyContent: 'flex-end',
          gap: '8px',
          marginTop: '8px',
        }}
      >
        <button
          type="button"
          style={inkButtonStyle({ color: INK_SOFT })}
          onClick={onClose}
        >
          Cancel
        </button>
        <button
          type="button"
          disabled={!canSend}
          title={sendTitle}
          style={inkButtonStyle({ color: SEAL_GREEN, disabled: !canSend })}
          onClick={() =>
            act('caravan_send', {
              caravan: draft.caravan,
              route: draft.route,
              orders: draft.stops,
            })
          }
        >
          Send {draft.caravanName}
        </button>
      </div>
    </div>
  );
};

const StopPanel = (props: {
  data: Data;
  stop: CaravanStopDraft;
  region: RegionRow | undefined;
  regionName: string;
  stockByGood: Record<string, number>;
  quoteStop?: { buy_cost: number; sell_revenue: number };
  onChange: (next: CaravanStopDraft) => void;
}) => {
  const { data, stop, region, regionName, stockByGood, quoteStop, onChange } =
    props;
  if (!region) return null;

  const setLine = (kind: LineKind, goodId: string, units: number) => {
    const lines = { ...stop[kind] };
    if (units > 0) {
      lines[goodId] = units;
    } else {
      delete lines[goodId];
    }
    const next = { ...stop };
    next[kind] = lines;
    onChange(next);
  };

  const buyRows = sortFlows(
    region.produces.filter(
      (f) =>
        !!data.good_catalog[f.good_id]?.importable && f.good_id in stockByGood,
    ),
    data,
  );
  const sellRows = sortFlows(
    region.demands.filter((f) => f.good_id in stockByGood),
    data,
  );
  const tributeRows = sortFlows(
    region.produces.filter(
      (f) => (f.tribute_price ?? 0) > 0 && f.good_id in stockByGood,
    ),
    data,
  );
  const tributeOpen = !region.tribute_claimed && !region.blockaded;
  const tributeSpent = tributeRows.reduce(
    (total, f) => total + (stop.tribute[f.good_id] ?? 0) * (f.tribute_price ?? 0),
    0,
  );

  return (
    <div
      style={{
        border: `1px solid ${INK_FAINT}`,
        borderRadius: '2px',
        padding: '6px 10px',
        marginTop: '8px',
      }}
    >
      <div style={{ display: 'flex', alignItems: 'baseline', gap: '10px' }}>
        <span style={{ fontWeight: 'bold', fontSize: FONT_BODY }}>
          {regionName}
        </span>
        {quoteStop && (
          <span style={{ color: INK_FAINT, fontSize: FONT_BODY }}>
            Buying for {formatMammon(quoteStop.buy_cost)}m &middot; Selling
            for {formatMammon(quoteStop.sell_revenue)}m
          </span>
        )}
        <span
          style={{
            marginLeft: 'auto',
            fontSize: FONT_BODY,
            color: tributeSpent > region.tribute_value ? SEAL_RED : INK_SOFT,
          }}
        >
          {tributeOpen
            ? `Tribute ${formatMammon(tributeSpent)} / ${formatMammon(region.tribute_value)}m`
            : 'Tribute already given today'}
        </span>
      </div>
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '1fr 1fr 1fr',
          gap: '12px',
          marginTop: '6px',
        }}
      >
        <LineColumn
          title="Buy here"
          color={SEAL_BLUE}
          rows={buyRows}
          lines={stop.buys}
          data={data}
          emptyText="Sells nothing the Crown can store."
          price={(f) => f.price}
          note={(f) => `${f.today} left`}
          noteTitle="Supply left today. Large orders cost more per unit."
          max={() => data.caravan_capacity}
          onSet={(goodId, units) => setLine('buys', goodId, units)}
        />
        <LineColumn
          title="Sell here"
          color={SEAL_GREEN}
          rows={sellRows}
          lines={stop.sells}
          data={data}
          emptyText="Buys nothing the Crown stores."
          price={(f) => f.price}
          note={(f) => `${stockByGood[f.good_id] ?? 0} held`}
          noteTitle="Royal stock on hand. Large orders fetch less per unit."
          max={(f) =>
            Math.min(data.caravan_capacity, stockByGood[f.good_id] ?? 0)
          }
          onSet={(goodId, units) => setLine('sells', goodId, units)}
        />
        <LineColumn
          title="Tribute"
          color={SEAL_AMBER}
          rows={tributeRows}
          lines={stop.tribute}
          data={data}
          emptyText="No tribute today."
          disabled={!tributeOpen}
          price={(f) => f.tribute_price ?? 0}
          note={() => ''}
          noteTitle=""
          max={(f) =>
            Math.floor(region.tribute_value / (f.tribute_price || 1))
          }
          onSet={(goodId, units) => setLine('tribute', goodId, units)}
        />
      </div>
    </div>
  );
};

const LineColumn = (props: {
  title: string;
  color: string;
  rows: RegionFlow[];
  lines: CaravanLines;
  data: Data;
  emptyText: string;
  disabled?: boolean;
  price: (f: RegionFlow) => number;
  note: (f: RegionFlow) => string;
  noteTitle: string;
  max: (f: RegionFlow) => number;
  onSet: (goodId: string, units: number) => void;
}) => {
  const { title, color, rows, lines, data, emptyText, disabled } = props;
  return (
    <div>
      <div style={columnHeaderStyle}>{title}</div>
      {!rows.length && <div style={emptyStyle}>{emptyText}</div>}
      {rows.map((f) => {
        const max = props.max(f);
        const off = !!disabled || max <= 0;
        const value = lines[f.good_id] ?? 0;
        const note = props.note(f);
        return (
          <div
            key={f.good_id}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '4px',
              fontSize: FONT_BODY,
              padding: '1px 0',
              opacity: off && !value ? 0.55 : 1,
            }}
          >
            <span style={ellipsisCellStyle}>
              {data.good_catalog[f.good_id]?.name ?? f.good_id}
            </span>
            <span style={{ color, whiteSpace: 'nowrap' }}>
              {formatMammon(props.price(f))}m
            </span>
            {!!note && (
              <span
                style={{ color: INK_FAINT, whiteSpace: 'nowrap' }}
                title={props.noteTitle}
              >
                {note}
              </span>
            )}
            <input
              type="number"
              min={0}
              max={max}
              disabled={off}
              value={value || ''}
              placeholder="0"
              style={{
                ...inkInputStyle,
                width: '46px',
                padding: '0 4px',
                textAlign: 'right',
              }}
              onChange={(e) => {
                const n = parseInt(e.target.value, 10);
                props.onSet(
                  f.good_id,
                  Number.isNaN(n) ? 0 : Math.max(0, Math.min(max, n)),
                );
              }}
            />
          </div>
        );
      })}
    </div>
  );
};

const CapacityBar = (props: {
  label: string;
  used: number;
  capacity: number;
  color: string;
}) => {
  const { label, used, capacity, color } = props;
  const over = used > capacity;
  const pct = Math.min(100, (used / Math.max(1, capacity)) * 100);
  return (
    <div style={{ flex: 1 }}>
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          fontSize: FONT_BODY,
        }}
      >
        <span style={{ color: INK_SOFT }}>{label}</span>
        <span style={{ color: over ? SEAL_RED : INK, fontWeight: 'bold' }}>
          {used} / {capacity}
        </span>
      </div>
      <div
        style={{
          height: '8px',
          border: `1px solid ${INK_FAINT}`,
          borderRadius: '2px',
          overflow: 'hidden',
          marginTop: '2px',
        }}
      >
        <div
          style={{
            width: `${pct}%`,
            height: '100%',
            background: over ? SEAL_RED : color,
          }}
        />
      </div>
    </div>
  );
};
