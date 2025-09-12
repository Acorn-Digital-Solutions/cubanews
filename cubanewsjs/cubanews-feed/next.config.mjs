/** @type {import('next').NextConfig} */
const nextConfig = {
  async redirects() {
    return [
      {
        source: "/",
        destination: "/home",
        permanent: true,
      },
    ];
  },
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.externals.push(
        "node-llama-cpp",
        "@reflink/reflink-darwin-arm64",
        "@node-llama-cpp/mac-x64",
        "@node-llama-cpp/linux-x64-cuda",
        "@node-llama-cpp/linux-x64-cuda-ext",
        "@node-llama-cpp/linux-x64-vulkan"
      );
    }
    return config;
  },
};

export default nextConfig;
