"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.Template = void 0;

var _react = _interopRequireWildcard(require("react"));

var _fonts = require("./fonts");

var _styles = require("./styles");

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) { var desc = Object.defineProperty && Object.getOwnPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : {}; if (desc.get || desc.set) { Object.defineProperty(newObj, key, desc); } else { newObj[key] = obj[key]; } } } } newObj.default = obj; return newObj; } }

/*
 * Licensed to Elasticsearch B.V. under one or more contributor
 * license agreements. See the NOTICE file distributed with
 * this work for additional information regarding copyright
 * ownership. Elasticsearch B.V. licenses this file to you under
 * the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
const Template = ({
  metadata: {
    uiPublicUrl,
    locale,
    darkMode,
    injectedMetadata,
    i18n,
    bootstrapScriptUrl,
    strictCsp
  }
}) => {
  return _react.default.createElement("html", {
    lang: locale
  }, _react.default.createElement("head", null, _react.default.createElement("meta", {
    charSet: "utf-8"
  }), _react.default.createElement("meta", {
    httpEquiv: "X-UA-Compatible",
    content: "IE=edge,chrome=1"
  }), _react.default.createElement("meta", {
    name: "viewport",
    content: "width=device-width"
  }), _react.default.createElement("title", null, "Kibana"), _react.default.createElement(_fonts.Fonts, {
    url: uiPublicUrl
  }), _react.default.createElement("link", {
    rel: "apple-touch-icon",
    sizes: "180x180",
    href: `${uiPublicUrl}/favicons/apple-touch-icon.png`
  }), _react.default.createElement("link", {
    rel: "icon",
    type: "image/png",
    sizes: "32x32",
    href: `${uiPublicUrl}/favicons/favicon-32x32.png`
  }), _react.default.createElement("link", {
    rel: "icon",
    type: "image/png",
    sizes: "16x16",
    href: `${uiPublicUrl}/favicons/favicon-16x16.png`
  }), _react.default.createElement("link", {
    rel: "manifest",
    href: `${uiPublicUrl}/favicons/manifest.json`
  }), _react.default.createElement("link", {
    rel: "mask-icon",
    color: "#e8488b",
    href: `${uiPublicUrl}/favicons/safari-pinned-tab.svg`
  }), _react.default.createElement("link", {
    rel: "shortcut icon",
    href: `${uiPublicUrl}/favicons/favicon.ico`
  }), _react.default.createElement("meta", {
    name: "msapplication-config",
    content: `${uiPublicUrl}/favicons/browserconfig.xml`
  }), _react.default.createElement("meta", {
    name: "theme-color",
    content: "#ffffff"
  }), _react.default.createElement(_styles.Styles, {
    darkMode: darkMode
  })), _react.default.createElement("body", null, (0, _react.createElement)('kbn-csp', {
    data: JSON.stringify({
      strictCsp
    })
  }), (0, _react.createElement)('kbn-injected-metadata', {
    data: JSON.stringify(injectedMetadata)
  }), _react.default.createElement("div", {
    className: "kibanaWelcomeView",
    id: "kbn_loading_message",
    style: {
      display: 'none'
    },
    "data-test-subj": "kbnLoadingMessage"
  }, _react.default.createElement("div", {
    className: "kibanaLoaderWrap"
  }, _react.default.createElement("div", {
    className: "kibanaLoader"
  }), _react.default.createElement("div", {
    className: "kibanaWelcomeLogoCircle"
  }, _react.default.createElement("div", {
    className: "kibanaWelcomeLogo"
  }))), _react.default.createElement("div", {
    className: "kibanaWelcomeText",
    "data-error-message": i18n('core.ui.welcomeErrorMessage', {
      defaultMessage: 'Kibana did not load properly. Check the server output for more information.'
    })
  }, i18n('core.ui.welcomeMessage', {
    defaultMessage: 'Loading PALallax'
  }))), _react.default.createElement("div", {
    className: "kibanaWelcomeView",
    id: "kbn_legacy_browser_error",
    style: {
      display: 'none'
    }
  }, _react.default.createElement("div", {
    className: "kibanaLoaderWrap"
  }, _react.default.createElement("div", {
    className: "kibanaWelcomeLogoCircle"
  }, _react.default.createElement("div", {
    className: "kibanaWelcomeLogo"
  }))), _react.default.createElement("h2", {
    className: "kibanaWelcomeTitle"
  }, i18n('core.ui.legacyBrowserTitle', {
    defaultMessage: 'Please upgrade your browser'
  })), _react.default.createElement("div", {
    className: "kibanaWelcomeText"
  }, i18n('core.ui.legacyBrowserMessage', {
    defaultMessage: 'This Kibana installation has strict security requirements enabled that your current browser does not meet.'
  }))), _react.default.createElement("script", null, `
            // Since this is an unsafe inline script, this code will not run
            // in browsers that support content security policy(CSP). This is
            // intentional as we check for the existence of __kbnCspNotEnforced__ in
            // bootstrap.
            window.__kbnCspNotEnforced__ = true;
          `), _react.default.createElement("script", {
    src: bootstrapScriptUrl
  })));
};

exports.Template = Template;
