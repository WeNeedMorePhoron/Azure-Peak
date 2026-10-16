import { useState } from 'react';
import { NumberInput } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  FONT_BODY,
  INK,
  INK_SOFT,
  inkButtonStyle,
  pageStyle,
  rulerStyle,
  SEAL_RED_SOFT,
  SERIF,
  sectionHeaderStyle,
} from './common/parchment';

type CategoryRate = {
  category: string;
  rate: number;
};

type Data = {
  categoryRates: CategoryRate[];
  concordatFloor: number;
  levyCooldown: boolean;
};

const rowStyle: React.CSSProperties = {
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'space-between',
  padding: '3px 0',
  borderBottom: '1px solid rgba(120,80,30,0.1)',
};

const labelStyle: React.CSSProperties = {
  fontFamily: SERIF,
  fontSize: FONT_BODY,
  color: INK,
};

export const TaxSetter = (props: any, context: any) => {
  const { act, data } = useBackend<Data>();
  const levyCooldown = !!data.levyCooldown;

  const [rates, setRates] = useState<Record<string, number>>(() => {
    if (!data.categoryRates) return {};
    return Object.fromEntries(
      data.categoryRates.map((c) => [c.category, c.rate]),
    );
  });

  const updateRate = (category: string, newRate: number) => {
    setRates((prev) => ({ ...prev, [category]: newRate }));
  };

  const payload = Object.entries(rates).map(([category, rate]) => ({
    category,
    rate,
  }));

  return (
    <Window width={380} height={480} title="Tax Roll" theme="parchment">
      <Window.Content scrollable>
        <div style={pageStyle}>
          <div
            style={{
              textAlign: 'center',
              fontSize: FONT_BODY,
              color: INK_SOFT,
              marginBottom: '10px',
            }}
          >
            You can change the levies once per day.
          </div>

          {levyCooldown && (
            <div
              style={{
                background: 'rgba(140,60,30,0.12)',
                border: `1px solid ${SEAL_RED_SOFT}`,
                color: SEAL_RED_SOFT,
                padding: '6px 10px',
                textAlign: 'center',

                fontWeight: 'bold',
                marginBottom: '10px',
              }}
            >
              You changed the levies today. Try again tomorrow.
            </div>
          )}

          <div style={sectionHeaderStyle}>Crown Levies</div>
          <div
            style={{
              fontSize: FONT_BODY,
              color: INK_SOFT,
              marginBottom: '8px',
            }}
          >
            The Crown takes this share of contract rewards, head bounties,
            imports, exports and recovered spoils. While the Concordat of
            Zenitstadt is in force, no levy can go below {data.concordatFloor}%.
          </div>
          {data.categoryRates?.map((c) => (
            <div key={c.category} style={rowStyle}>
              <span style={labelStyle}>{c.category}</span>
              <NumberInput
                step={1}
                minValue={0}
                maxValue={100}
                unit="%"
                value={rates[c.category] ?? c.rate}
                onChange={(v: number) => updateRate(c.category, v)}
              />
            </div>
          ))}
          <hr style={rulerStyle} />
          <div style={{ textAlign: 'center' }}>
            <button
              disabled={levyCooldown}
              style={{
                ...inkButtonStyle({ disabled: levyCooldown }),
                padding: '5px 24px',
                fontSize: FONT_BODY,
              }}
              onClick={() =>
                !levyCooldown && act('set_rates', { categoryRates: payload })
              }
            >
              Set Levies
            </button>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
