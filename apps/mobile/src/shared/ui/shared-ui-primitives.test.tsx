import { Text } from 'react-native';
import { screen } from '@testing-library/react-native';
import { describe, expect, it, jest } from '@jest/globals';

import { OfflineBanner } from './OfflineBanner';
import { InfoCard } from './InfoCard';
import { renderWithProviders } from '../../test-utils/render';

describe('shared UI primitives', () => {
  it('renders InfoCard title, subtitle, and content together', () => {
    renderWithProviders(
      <InfoCard title="프레임 프리셋" subtitle="@phos/shared의 공통 계약 데이터">
        <Text>프리셋 콘텐츠</Text>
      </InfoCard>,
    );

    expect(screen.getByText('프레임 프리셋')).toBeTruthy();
    expect(screen.getByText('@phos/shared의 공통 계약 데이터')).toBeTruthy();
    expect(screen.getByText('프리셋 콘텐츠')).toBeTruthy();
  });

  it('renders OfflineBanner message and retry action only in offline state', () => {
    const retry = jest.fn();

    renderWithProviders(<OfflineBanner isOffline message="오프라인 안내" onRetry={retry} />);

    expect(screen.getByText('오프라인 안내')).toBeTruthy();
    expect(screen.getByRole('button', { name: '재시도' })).toBeTruthy();
  });

  it('does not render OfflineBanner when online', () => {
    renderWithProviders(<OfflineBanner isOffline={false} />);

    expect(
      screen.queryByText('인터넷 연결이 없습니다. 일부 부스 기능을 사용할 수 없어요.'),
    ).toBeNull();
  });
});
