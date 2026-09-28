import {
  bannerStyle,
  FONT_BODY,
  FONT_TITLE,
  INK,
  SEAL_AMBER,
} from '../common/parchment';
import type { SequestrationState } from './types';

export const ArrearsBanner = (props: { sequestration: SequestrationState }) => {
  const { sequestration } = props;
  if (!sequestration?.in_arrears) {
    return null;
  }
  return (
    <div
      style={{
        ...bannerStyle(SEAL_AMBER),
        position: 'relative',
        fontSize: FONT_BODY,
        padding: '10px 14px',
      }}
    >
      <div
        style={{
          fontSize: FONT_TITLE,
          fontWeight: 'bold',
          marginBottom: '3px',
          color: SEAL_AMBER,
        }}
      >
        ARREARS WITH THE BURGHERS
      </div>
      <div style={{ fontVariant: 'normal', color: INK }}>
        The Crown owes <b>{sequestration.debt}m</b> in arrears to the Burghers.
        All inflow into the Treasury is skimmed until it is settled. Should the
        Crown miss the next dawn's payroll, the realm enters sequestration.
      </div>
    </div>
  );
};
