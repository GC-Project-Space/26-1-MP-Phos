module.exports = {
  testEnvironment: 'node',
  testTimeout: 10000,
  transform: {
    '^.+\\.[jt]sx?$': ['babel-jest', { presets: ['babel-preset-expo'] }],
  },
};
