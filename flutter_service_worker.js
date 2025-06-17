'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "8c56cb7d634fdd151217b3541aaeb699",
"assets/AssetManifest.bin": "457b161559393cf47586c497b3f25f36",
"assets/fonts/MaterialIcons-Regular.otf": "c6dede8bad2925f6cf00f4c2b44f718b",
"assets/AssetManifest.json": "6b66a7a00d54bf2bc514366c13baaffc",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/assets/icons/delete.svg": "69337bee96e148526e400b2a411e69ba",
"assets/assets/icons/obd_logo.svg": "afed0fa223798c6d4ad55da17e310bb2",
"assets/assets/icons/logo.png": "3d02ce4de028b5182c92517408a5a190",
"assets/assets/icons/iqlogo.png": "fb429e4f463b7fc9995c7cfee7532d41",
"assets/assets/icons/edit.svg": "a6b8d4794d3a81371cc44f115174fb37",
"assets/assets/icons/hide.svg": "3b5b453480a95c155b98d29c92c92f78",
"assets/assets/icons/show.svg": "c937108a2c2e43f8bf5ac07bd62ccda3",
"assets/assets/icons/logo2.png": "959d8efffa312b931de5de978cd6a924",
"assets/assets/icons/logo1.png": "ee4da9ad77101beba6c053c79eef1bfe",
"assets/assets/icons/swap.svg": "4bf0c3beb2d49a6e1af67f76c8935dd9",
"assets/assets/icons/swap1.svg": "ffefc709e894d056a54b8d331e2a4490",
"assets/assets/icons/user.svg": "836e296c1af6485c3bbea800fc9d3299",
"assets/assets/images/cart.png": "ad528492137694691e74ce35d1a5b037",
"assets/assets/images/bg3.jpg": "791bc8aabaea45a17dcd8cef16fad64a",
"assets/assets/images/bike.png": "78eb76a55b05307c1d2a484f615ce354",
"assets/assets/images/bg.jpg": "c6cdb3dd255e8cfd90f632ce9fd3a3fc",
"assets/assets/images/truck.png": "6190c3b5091ed01af6b4eba18347185a",
"assets/assets/images/bg2.jpg": "c9d87d6d5290637e320ab2183ad46dd3",
"assets/assets/images/cart1.png": "6ba697b6dacb2164b6bfc25d9be9a636",
"assets/assets/images/telematics_web.jpg": "abe8574783aed4de52d9b90cac32d145",
"assets/assets/images/bg1.jpg": "cb5080a8a9965278016c44c29ee6f69a",
"assets/assets/images/car.png": "a54ec724b24a5b428fcb9e60595b5ee7",
"assets/assets/images/truck2.png": "71c60c8f501451792df0899cabd11dfa",
"assets/assets/images/bg4.jpg": "baaf7e7327f57646c74eb336ad47ed53",
"assets/assets/images/bg5.jpg": "be9d4b06b6643761041a26ccd57b332c",
"assets/NOTICES": "76b15e0ecfa314b676009dd47c36f673",
"assets/AssetManifest.bin.json": "b0022f922434ee963add40ab91afb281",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"manifest.json": "d6c8dc8ce663c6ca9519a95d5d634929",
"index.html": "7260fe58d6f3f4669b1f56ca4318fd2b",
"/": "7260fe58d6f3f4669b1f56ca4318fd2b",
"version.json": "ec98b7a173e134177541db0c7d80697d",
"flutter_bootstrap.js": "2507a4c56e3cdbd81d8645e9bb66b15c",
"main.dart.js": "78b17a765d31e9e1264957ab9088fdbe",
"favicon.png": "5dcef449791fa27946b3d35ad8803796"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
