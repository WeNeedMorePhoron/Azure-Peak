import { formatMammon } from '../common/format';
import {
  cardStyle,
  FONT_BODY,
  INK_FAINT,
  INK_SOFT,
  PARCHMENT_SHADOW,
  SEAL_AMBER,
  sectionHeaderStyle,
} from '../common/parchment';
import type { Caravan, Data } from './types';

const formatReturn = (seconds: number) => {
  const minutes = Math.ceil(seconds / 60);
  return minutes <= 1 ? 'a minute' : `${minutes} minutes`;
};

export const CaravansView = (props: { data: Data }) => {
  const { data } = props;
  return (
    <div>
      <div style={sectionHeaderStyle}>Caravans</div>
      {data.caravans.map((caravan) => (
        <CaravanCard key={caravan.ref} caravan={caravan} />
      ))}
    </div>
  );
};

const CaravanCard = (props: { caravan: Caravan }) => {
  const { caravan } = props;
  const onRoad = !!caravan.on_road;
  const estimate = caravan.market_estimate ?? 0;
  return (
    <div
      style={{
        ...cardStyle,
        borderLeft: `4px solid ${onRoad ? SEAL_AMBER : PARCHMENT_SHADOW}`,
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
        <span style={{ fontWeight: 'bold', fontSize: FONT_BODY }}>
          {caravan.name}
        </span>
        <span style={{ color: INK_SOFT, fontSize: FONT_BODY }}>
          {onRoad
            ? `On ${caravan.route_name}. Back in ${formatReturn(caravan.returns_in ?? 0)}.`
            : 'At home.'}
        </span>
      </div>
      {onRoad && (
        <div style={{ color: INK_FAINT, fontSize: FONT_BODY, marginTop: '2px' }}>
          {caravan.sell_units} out, {caravan.buy_units} in &middot; paid{' '}
          {formatMammon(caravan.buy_cost)}m &middot; brings{' '}
          {formatMammon(caravan.sell_revenue)}m in sales
          {estimate > 0
            ? ` and about ${formatMammon(estimate)}m from the Market`
            : ''}
          {caravan.tribute_units
            ? ` · tribute: ${caravan.tribute_units} ${caravan.tribute_name}`
            : ''}
          {caravan.booked_by ? ` · sent by ${caravan.booked_by}` : ''}
        </div>
      )}
    </div>
  );
};
