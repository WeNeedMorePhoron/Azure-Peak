import { Box, Button, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  ELLIPSIS,
  FILTER_ALL,
  filterLabel,
  type GameMasterData,
  ROW,
  TRAILING,
} from './types';

type Props = {
  query: string;
  onQuery: (value: string) => void;
};

export function FactionRail(props: Props) {
  const { query, onQuery } = props;
  const { act, data } = useBackend<GameMasterData>();
  const {
    selected_filter,
    pinned_factions = [],
    spawn_filters = [],
    filter_counts = {},
    max_pinned,
  } = data;

  const needle = query.toLowerCase();
  const matches = spawn_filters.filter((value) =>
    filterLabel(value).toLowerCase().includes(needle),
  );
  const pinned = matches.filter((value) => pinned_factions.includes(value));
  const rest = matches.filter((value) => !pinned_factions.includes(value));

  function renderRow(value: string) {
    const isPinned = pinned_factions.includes(value);
    const pinnable = value !== FILTER_ALL;
    const atCap = !isPinned && pinned_factions.length >= max_pinned;

    return (
      <Stack key={value} align="center" mb={0.2}>
        <Stack.Item grow style={{ minWidth: 0 }}>
          <Button
            fluid
            compact
            selected={selected_filter === value}
            onClick={() => {
              act('set_selected_filter', { new_filter: value });
            }}
          >
            <Box style={ROW}>
              <Box style={ELLIPSIS}>{filterLabel(value)}</Box>
              <Box style={TRAILING}>{filter_counts[value] ?? 0}</Box>
            </Box>
          </Button>
        </Stack.Item>
        {!!pinnable && (
          <Stack.Item shrink={0}>
            <Button
              compact
              icon="thumbtack"
              color="transparent"
              selected={isPinned}
              disabled={atCap}
              tooltip={
                isPinned
                  ? 'Unpin'
                  : atCap
                    ? `Already pinned ${max_pinned}`
                    : 'Pin to top'
              }
              onClick={() => {
                act('toggle_pin_faction', { faction: value });
              }}
            />
          </Stack.Item>
        )}
      </Stack>
    );
  }

  return (
    <Section fill title="Factions">
      <Stack fill vertical>
        <Stack.Item>
          <Input
            fluid
            placeholder="Filter..."
            value={query}
            onChange={onQuery}
          />
        </Stack.Item>
        <Stack.Item
          grow
          mt={0.5}
          style={{ overflowY: 'auto', overflowX: 'hidden', minWidth: 0 }}
        >
          {pinned.length > 0 && (
            <>
              <Box color="label" fontSize="0.8rem">
                Pinned
              </Box>
              {pinned.map(renderRow)}
              <Box color="label" fontSize="0.8rem" mt={0.5}>
                All
              </Box>
            </>
          )}
          {rest.map(renderRow)}
        </Stack.Item>
      </Stack>
    </Section>
  );
}
