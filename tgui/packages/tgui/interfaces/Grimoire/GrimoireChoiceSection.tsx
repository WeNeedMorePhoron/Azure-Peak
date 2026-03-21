import { cls, stripHtml } from './helpers';
import { type Aspect } from './types';

export const GrimoireChoiceSection = ({
  aspect,
  stagedChoices,
  allSelectedSpells,
  act,
}: {
  aspect: Aspect;
  stagedChoices: Record<string, string>;
  allSelectedSpells: string[];
  act: (action: string, params: Record<string, unknown>) => void;
}) => {
  const currentChoice = stagedChoices[aspect.path] || null;

  return (
    <div>
      <div className="AspectPicker__divider" />
      <div className="AspectPicker__section-label">Choose One</div>
      {aspect.choice_spells.map((spell) => {
        const isSelected = currentChoice === spell.path;
        const selectedElsewhere =
          !isSelected && allSelectedSpells.includes(spell.path);
        return (
          <div
            key={spell.path}
            className={cls(
              'AspectPicker__pointbuy-entry',
              isSelected && 'AspectPicker__pointbuy-entry--selected',
              selectedElsewhere && 'AspectPicker__pointbuy-entry--disabled',
            )}
            title={spell.desc ? stripHtml(spell.desc) : undefined}
            onClick={() =>
              !selectedElsewhere &&
              act('choice_toggle', {
                aspect_path: aspect.path,
                spell_path: spell.path,
              })
            }
          >
            {spell.name}
            {selectedElsewhere && (
              <span
                className="AspectPicker__spell-desc"
                style={{ marginLeft: '6px' }}
              >
                already inscribed
              </span>
            )}
          </div>
        );
      })}
    </div>
  );
};
