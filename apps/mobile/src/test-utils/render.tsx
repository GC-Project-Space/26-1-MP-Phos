import type { PropsWithChildren, ReactElement } from 'react';
import { render } from '@testing-library/react-native';

import { AppProviders, type AppRuntime } from '../app/providers/AppProviders';

interface RenderWithProvidersOptions {
  runtime?: AppRuntime;
}

function Providers({ children, runtime }: PropsWithChildren<RenderWithProvidersOptions>) {
  return <AppProviders runtime={runtime}>{children}</AppProviders>;
}

export function renderWithProviders(ui: ReactElement, options: RenderWithProvidersOptions = {}) {
  const { runtime } = options;

  return render(ui, {
    wrapper: ({ children }) => <Providers runtime={runtime}>{children}</Providers>,
  });
}
