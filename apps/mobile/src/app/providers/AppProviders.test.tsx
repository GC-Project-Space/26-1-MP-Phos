import { Text } from 'react-native';
import { render, screen } from '@testing-library/react-native';
import { describe, expect, it } from '@jest/globals';

import { AppProviders, useAppRuntime } from './AppProviders';

function RuntimeProbe() {
  const runtime = useAppRuntime();

  return <Text>{runtime.appDisplayName}</Text>;
}

describe('AppProviders', () => {
  it('throws a descriptive error when runtime hook is used without provider', () => {
    expect(() => render(<RuntimeProbe />)).toThrow(
      'useAppRuntime must be used within AppProviders',
    );
  });

  it('provides runtime values to descendants', () => {
    render(
      <AppProviders
        runtime={{
          appDisplayName: '테스트 런타임',
          offlineBannerEnabled: false,
        }}
      >
        <RuntimeProbe />
      </AppProviders>,
    );

    expect(screen.getByText('테스트 런타임')).toBeTruthy();
  });
});
