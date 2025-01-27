import { NextConfig } from 'next';

const nextConfig: NextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  devIndicators: {
    buildActivity: true, // Enable IP address change to expose to local network
  },
  webpack: (config, { isServer }) => {
    // Modify webpack configuration for file watching
    config.watchOptions = {
      poll: 10000, // Set the polling interval (milliseconds)
      aggregateTimeout: 300, // Delay before restarting the build after changes
    };

    return config;
  },
};

export default nextConfig;
