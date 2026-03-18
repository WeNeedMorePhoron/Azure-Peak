import { useState } from 'react';
import { Box, Button, Divider, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Spell = {
  path: string;
  name: string;
  desc: string;
  cost: number;
};

type Aspect = {
  path: string;
  name: string;
  desc: string;
  fluff_desc: string;
  aspect_type: string;
  attuned_name: string;
  school_color: string;
  pointbuy_budget: number;
  fixed_spells: Spell[];
  pointbuy_spells: Spell[];
  countersynergy: string[];
};

type Data = {
  major_aspects: Aspect[];
  minor_aspects: Aspect[];
  user_tier: number;
  max_majors: number;
  max_minors: number;
  initial_setup: boolean;
  attuned_majors: string[];
  attuned_minors: string[];
  pointbuy_selections: Record<string, string[]>;
  all_selected_spells: string[];
  spent_budgets: Record<string, number>;
};

export const AspectPicker = () => {
  const { data, act } = useBackend<Data>();
  const {
    major_aspects = [],
    minor_aspects = [],
    max_majors = 1,
    max_minors = 2,
    initial_setup = true,
    attuned_majors = [],
    attuned_minors = [],
    pointbuy_selections = {},
    all_selected_spells = [],
  } = data;

  const [selectedPath, setSelectedPath] = useState<string | null>(null);
  const [tab, setTab] = useState<'major' | 'minor'>('major');

  const aspects = tab === 'major' ? major_aspects : minor_aspects;
  const attuned = tab === 'major' ? attuned_majors : attuned_minors;
  const maxSlots = tab === 'major' ? max_majors : max_minors;
  const slotsUsed = attuned.length;
  const slotsFull = slotsUsed >= maxSlots;

  const selected = aspects.find((a) => a.path === selectedPath) || null;
  const isAttuned = selected ? attuned.includes(selected.path) : false;

  const allAttuned = [...attuned_majors, ...attuned_minors];
  const allAspects = [...major_aspects, ...minor_aspects];

  const isBlocked = (aspect: Aspect): boolean => {
    for (const counterPath of aspect.countersynergy) {
      if (allAttuned.includes(counterPath)) {
        return true;
      }
    }
    for (const attunedPath of allAttuned) {
      const attunedAspect = allAspects.find((a) => a.path === attunedPath);
      if (attunedAspect?.countersynergy.includes(aspect.path)) {
        return true;
      }
    }
    return false;
  };

  const getPointbuyUsed = (aspect: Aspect): number => {
    const selections = pointbuy_selections[aspect.path] || [];
    let total = 0;
    for (const spellPath of selections) {
      const spell = aspect.pointbuy_spells.find((s) => s.path === spellPath);
      if (spell) {
        total += spell.cost;
      }
    }
    return total;
  };

  return (
    <Window width={820} height={560} title="Arcyne Aspects">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  textAlign="center"
                  selected={tab === 'major'}
                  onClick={() => {
                    setTab('major');
                    setSelectedPath(null);
                  }}
                >
                  Major Aspects ({attuned_majors.length}/{max_majors})
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  textAlign="center"
                  selected={tab === 'minor'}
                  onClick={() => {
                    setTab('minor');
                    setSelectedPath(null);
                  }}
                >
                  Minor Aspects ({attuned_minors.length}/{max_minors})
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item basis="35%">
                <Section title="Disciplines" fill scrollable>
                  {aspects.map((aspect) => {
                    const active = attuned.includes(aspect.path);
                    const blocked = !active && isBlocked(aspect);
                    return (
                      <Button
                        key={aspect.path}
                        fluid
                        selected={selectedPath === aspect.path}
                        color={
                          active ? 'good' : blocked ? 'grey' : undefined
                        }
                        opacity={blocked ? 0.5 : 1}
                        onClick={() => setSelectedPath(aspect.path)}
                        mb={0.5}
                      >
                        {aspect.name}
                        {active ? ' \u2713' : ''}
                      </Button>
                    );
                  })}
                </Section>
              </Stack.Item>
              <Stack.Item grow basis={0}>
                {selected ? (
                  <Stack vertical fill>
                    <Stack.Item grow basis={0}>
                      <Section title={selected.name} fill scrollable>
                        {selected.fluff_desc && (
                          <Box
                            italic
                            color="label"
                            mb={1}
                            dangerouslySetInnerHTML={{
                              __html: selected.fluff_desc,
                            }}
                          />
                        )}
                        <Box
                          mb={1}
                          dangerouslySetInnerHTML={{
                            __html: selected.desc,
                          }}
                        />
                        {selected.attuned_name && (
                          <Box color="label" mb={1}>
                            Implement attunement: &quot;
                            {selected.attuned_name}&quot;
                          </Box>
                        )}
                        <Divider />
                        {selected.fixed_spells.length > 0 && (
                          <Box mb={1}>
                            <Box bold mb={0.5}>
                              Spells
                            </Box>
                            {selected.fixed_spells.map((spell) => (
                              <Box key={spell.path} ml={1} mb={0.5}>
                                <Box bold inline>
                                  {spell.name}
                                </Box>
                                {spell.desc && (
                                  <Box
                                    color="label"
                                    ml={1}
                                    inline
                                    dangerouslySetInnerHTML={{
                                      __html: spell.desc,
                                    }}
                                  />
                                )}
                              </Box>
                            ))}
                          </Box>
                        )}
                        {selected.pointbuy_spells.length > 0 && (
                          <Box>
                            <Box bold mb={0.5}>
                              Point-Buy ({getPointbuyUsed(selected)}/
                              {selected.pointbuy_budget})
                            </Box>
                            {selected.pointbuy_spells.map((spell) => {
                              const selections =
                                pointbuy_selections[selected.path] || [];
                              const isSelected = selections.includes(
                                spell.path,
                              );
                              const selectedElsewhere =
                                !isSelected &&
                                all_selected_spells.includes(spell.path);
                              const used = getPointbuyUsed(selected);
                              const wouldExceed =
                                !isSelected &&
                                used + spell.cost > selected.pointbuy_budget;
                              const isDisabled =
                                !isSelected &&
                                (wouldExceed || selectedElsewhere);
                              return (
                                <Button
                                  key={spell.path}
                                  fluid
                                  selected={isSelected}
                                  disabled={isDisabled}
                                  color={
                                    isSelected
                                      ? 'good'
                                      : selectedElsewhere
                                        ? 'grey'
                                        : undefined
                                  }
                                  opacity={selectedElsewhere ? 0.5 : 1}
                                  onClick={() =>
                                    act('pointbuy_toggle', {
                                      aspect_path: selected.path,
                                      spell_path: spell.path,
                                    })
                                  }
                                  mb={0.5}
                                >
                                  <span>
                                    {spell.name} ({spell.cost}pts)
                                    {selectedElsewhere && ' (already selected)'}
                                    {spell.desc && !selectedElsewhere && (
                                      <span
                                        dangerouslySetInnerHTML={{
                                          __html: ` - ${spell.desc}`,
                                        }}
                                      />
                                    )}
                                  </span>
                                </Button>
                              );
                            })}
                          </Box>
                        )}
                      </Section>
                    </Stack.Item>
                    <Stack.Item>
                      {isAttuned ? (
                        initial_setup ? (
                          <Button
                            fluid
                            textAlign="center"
                            color="bad"
                            fontSize={1.2}
                            onClick={() =>
                              act('remove', { path: selected.path })
                            }
                          >
                            Remove {selected.name}
                          </Button>
                        ) : (
                          <Box
                            textAlign="center"
                            color="good"
                            italic
                            py={0.5}
                          >
                            Currently attuned.
                          </Box>
                        )
                      ) : isBlocked(selected) ? (
                        <Box textAlign="center" color="bad" italic py={0.5}>
                          Conflicts with a current attunement.
                        </Box>
                      ) : slotsFull ? (
                        <Box textAlign="center" color="bad" italic py={0.5}>
                          No {tab} aspect slots remaining.
                        </Box>
                      ) : (
                        <Button
                          fluid
                          textAlign="center"
                          color="good"
                          fontSize={1.2}
                          onClick={() =>
                            act('attune', { path: selected.path })
                          }
                        >
                          Attune to {selected.name}
                        </Button>
                      )}
                    </Stack.Item>
                  </Stack>
                ) : (
                  <Section title="Select a Discipline" fill>
                    <Box color="label">
                      Choose a {tab} aspect from the left to view its details.
                    </Box>
                  </Section>
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Button
              fluid
              textAlign="center"
              color="good"
              fontSize={1.1}
              disabled={attuned_majors.length === 0}
              onClick={() => act('confirm')}
            >
              Confirm Aspects
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
