const path = require('path');
const webpack = require('webpack');

module.exports = {
  mode: 'production',
  entry: './src/app.js',
  // entry: path.resolve(__dirname, 'src') + '/app.js',
  output: {
    filename: 'bundle.js',
    path: path.join(__dirname, 'public')
  },
}

// const { VueLoaderPlugin } = require('vue-loader')

// module.exports = {
//   mode: 'development',
//   entry: [
//     './src/app.js'
//   ],
//   module: {
//     rules: [
//       {
//         test: /\.vue$/,
//         use: 'vue-loader'
//       }
//     ]
//   },
//   plugins: [
//     new VueLoaderPlugin()
//   ]
// }

