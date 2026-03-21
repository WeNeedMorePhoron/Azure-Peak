import { type Spell } from './types';

export const GrimoireSpellEntry = ({ spell }: { spell: Spell }) => (
  <div className="AspectPicker__spell-entry">
    <span className="AspectPicker__spell-name">{spell.name}</span>
    {spell.desc && (
      <div
        className="AspectPicker__spell-desc"
        dangerouslySetInnerHTML={{ __html: spell.desc }}
      />
    )}
  </div>
);
