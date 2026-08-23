import { Box, Button, Section, Stack } from 'tgui-core/components';

export function CommandBand(props) {
  return (
    <Section title="Command">
      <Stack align="center">
        <Stack.Item>
          <Button disabled>Behaviour</Button>
        </Stack.Item>
        <Stack.Item>
          <Button disabled>Objective</Button>
        </Stack.Item>
        <Stack.Item>
          <Button disabled>Narrate</Button>
        </Stack.Item>
        <Stack.Item grow>
          <Box color="label" textAlign="right" fontSize="0.85rem">
            Reserved - click-intercept tools goes here.
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
