import {
  FONT_BODY,
  FONT_SMALL,
  INK,
  INK_FAINT,
  INK_SOFT,
  SERIF,
} from '../common/parchment';
import type { TabKey, TradeTabKey, TreasuryTabKey } from './types';

const tabBarStyle = {
  display: 'flex',
  flexWrap: 'wrap' as const,
  alignItems: 'center',
  gap: '4px',
  margin: '8px 0 4px 0',
};

const groupLabelStyle = {
  fontFamily: SERIF,
  fontSize: FONT_SMALL,
  color: INK_FAINT,
  textTransform: 'uppercase' as const,
  letterSpacing: '0.05em',
  marginRight: '2px',
};

const tabStyle = (active: boolean) => ({
  fontFamily: SERIF,
  fontSize: FONT_BODY,
  padding: '2px 8px',
  color: active ? INK : INK_FAINT,
  background: active ? 'rgba(200,170,100,0.25)' : 'transparent',
  border: `1px solid ${active ? INK_SOFT : 'transparent'}`,
  borderRadius: '2px',
  cursor: 'pointer',
  fontWeight: active ? ('bold' as const) : ('normal' as const),
  whiteSpace: 'nowrap' as const,
});

const TREASURY_TABS: { key: TreasuryTabKey; label: string }[] = [
  { key: 'accounts', label: 'Accounts' },
  { key: 'payroll', label: 'Daily Payments' },
  { key: 'debts', label: 'Debts & Arrears' },
  { key: 'fiscal', label: 'Fiscal Ledger' },
];

const TRADE_TABS: { key: TradeTabKey; label: string }[] = [
  { key: 'orders', label: 'Standing Orders' },
  { key: 'market', label: 'Market' },
  { key: 'regions', label: 'Regions' },
  { key: 'auto_import', label: 'Autoimport' },
  { key: 'petition', label: 'Petition' },
  { key: 'ledger', label: 'Ledger' },
  { key: 'royal_custom', label: 'Royal Custom' },
  { key: 'advanced', label: 'Advanced' },
];

export const isTreasuryTab = (tab: TabKey): tab is TreasuryTabKey =>
  TREASURY_TABS.some((t) => t.key === tab);

export const TabBar = (props: {
  tab: TabKey;
  onSwitch: (t: TabKey) => void;
  treasuryTabs: TreasuryTabKey[];
}) => {
  const { tab, onSwitch, treasuryTabs } = props;
  const treasury = TREASURY_TABS.filter((t) => treasuryTabs.includes(t.key));
  return (
    <>
      {treasury.length > 0 && (
        <div style={tabBarStyle}>
          <span style={groupLabelStyle}>Treasury</span>
          {treasury.map((t) => (
            <div
              key={t.key}
              style={tabStyle(tab === t.key)}
              onClick={() => onSwitch(t.key)}
            >
              {t.label}
            </div>
          ))}
        </div>
      )}
      <div style={tabBarStyle}>
        {treasury.length > 0 && <span style={groupLabelStyle}>Trade</span>}
        {TRADE_TABS.map((t) => (
          <div
            key={t.key}
            style={tabStyle(tab === t.key)}
            onClick={() => onSwitch(t.key)}
          >
            {t.label}
          </div>
        ))}
      </div>
    </>
  );
};
