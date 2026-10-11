/** @type {import('next').NextConfig} */

const nextConfig = {
  output: 'export',
  distDir: '../public',
  env: {
    name: 'My Workspace',
    description: 'Workspace DFIR & AI',
    icon: '/img/logo.svg',
    listUrl: 'https://shyr0x77.github.io/kasm-registry/',
    contactUrl: 'https://github.com/shyr0x77/kasm-registry/issues',
  },
  reactStrictMode: true,
  basePath: '/kasm-registry/1.0',
  trailingSlash: true,
  images: {
    unoptimized: true,
  }
}

module.exports = nextConfig
