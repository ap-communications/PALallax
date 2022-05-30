"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.Template = void 0;

var _react = _interopRequireWildcard(require("react"));

var _utils = require("../../../utils");

var _fonts = require("./fonts");

var _styles = require("./styles");

var _logo = require("./logo");

function _getRequireWildcardCache(nodeInterop) { if (typeof WeakMap !== "function") return null; var cacheBabelInterop = new WeakMap(); var cacheNodeInterop = new WeakMap(); return (_getRequireWildcardCache = function (nodeInterop) { return nodeInterop ? cacheNodeInterop : cacheBabelInterop; })(nodeInterop); }

function _interopRequireWildcard(obj, nodeInterop) { if (!nodeInterop && obj && obj.__esModule) { return obj; } if (obj === null || typeof obj !== "object" && typeof obj !== "function") { return { default: obj }; } var cache = _getRequireWildcardCache(nodeInterop); if (cache && cache.has(obj)) { return cache.get(obj); } var newObj = {}; var hasPropertyDescriptor = Object.defineProperty && Object.getOwnPropertyDescriptor; for (var key in obj) { if (key !== "default" && Object.prototype.hasOwnProperty.call(obj, key)) { var desc = hasPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : null; if (desc && (desc.get || desc.set)) { Object.defineProperty(newObj, key, desc); } else { newObj[key] = obj[key]; } } } newObj.default = obj; if (cache) { cache.set(obj, newObj); } return newObj; }

/*
 * Copyright Elasticsearch B.V. and/or licensed to Elasticsearch B.V. under one
 * or more contributor license agreements. Licensed under the Elastic License
 * 2.0 and the Server Side Public License, v 1; you may not use this file except
 * in compliance with, at your election, the Elastic License 2.0 or the Server
 * Side Public License, v 1.
 */
const Template = ({
  metadata: {
    uiPublicUrl,
    locale,
    darkMode,
    stylesheetPaths,
    injectedMetadata,
    i18n,
    bootstrapScriptUrl,
    strictCsp
  }
}) => {
  return /*#__PURE__*/_react.default.createElement("html", {
    lang: locale
  }, /*#__PURE__*/_react.default.createElement("head", null, /*#__PURE__*/_react.default.createElement("meta", {
    charSet: "utf-8"
  }), /*#__PURE__*/_react.default.createElement("meta", {
    httpEquiv: "X-UA-Compatible",
    content: "IE=edge,chrome=1"
  }), /*#__PURE__*/_react.default.createElement("meta", {
    name: "viewport",
    content: "width=device-width"
  }), /*#__PURE__*/_react.default.createElement("title", null, "PALallax"), /*#__PURE__*/_react.default.createElement(_fonts.Fonts, {
    url: uiPublicUrl
  }), /*#__PURE__*/_react.default.createElement("link", {
    rel: "alternate icon",
    type: "image/png",
    href: `${uiPublicUrl}/favicons/favicon.png`
  }), /*#__PURE__*/_react.default.createElement("link", {
    rel: "icon",
    type: "image/svg+xml",
    href: `${uiPublicUrl}/favicons/favicon.svg`
  }), /*#__PURE__*/_react.default.createElement("meta", {
    name: "theme-color",
    content: "#ffffff"
  }), /*#__PURE__*/_react.default.createElement("meta", {
    name: "color-scheme",
    content: "light dark"
  }), /*#__PURE__*/_react.default.createElement("meta", {
    name: _utils.EUI_STYLES_GLOBAL
  }), /*#__PURE__*/_react.default.createElement(_styles.Styles, {
    darkMode: darkMode,
    stylesheetPaths: stylesheetPaths
  }), /*#__PURE__*/_react.default.createElement("meta", {
    name: "add-styles-here"
  }), /*#__PURE__*/_react.default.createElement("meta", {
    name: "add-scripts-here"
  })), /*#__PURE__*/_react.default.createElement("body", null, /*#__PURE__*/(0, _react.createElement)('kbn-csp', {
    data: JSON.stringify({
      strictCsp
    })
  }), /*#__PURE__*/(0, _react.createElement)('kbn-injected-metadata', {
    data: JSON.stringify(injectedMetadata)
  }), /*#__PURE__*/_react.default.createElement("div", {
    className: "kbnWelcomeView",
    id: "kbn_loading_message",
    style: {
      display: 'none'
    },
    "data-test-subj": "kbnLoadingMessage"
  }, /*#__PURE__*/_react.default.createElement("div", {
    className: "kbnLoaderWrap"
  }, /*#__PURE__*/_react.default.createElement(_logo.Logo, null), /*#__PURE__*/_react.default.createElement("div", {
    className: "kbnWelcomeText",
    "data-error-message": i18n('core.ui.welcomeErrorMessage', {
      defaultMessage: 'Elastic did not load properly. Check the server output for more information.'
    })
  }, i18n('core.ui.welcomeMessage', {
    defaultMessage: 'Loading PALallax'
  })), /*#__PURE__*/_react.default.createElement("div", {
    className: "kbnProgress"
  }))), /*#__PURE__*/_react.default.createElement("div", {
    className: "kbnWelcomeView",
    id: "kbn_legacy_browser_error",
    style: {
      display: 'none'
    }
  }, /*#__PURE__*/_react.default.createElement(_logo.Logo, null), /*#__PURE__*/_react.default.createElement("h2", {
    className: "kbnWelcomeTitle"
  }, i18n('core.ui.legacyBrowserTitle', {
    defaultMessage: 'Please upgrade your browser'
  })), /*#__PURE__*/_react.default.createElement("div", {
    className: "kbnWelcomeText"
  }, i18n('core.ui.legacyBrowserMessage', {
    defaultMessage: 'This Elastic installation has strict security requirements enabled that your current browser does not meet.'
  }))), /*#__PURE__*/_react.default.createElement("script", null, `
            // Since this is an unsafe inline script, this code will not run
            // in browsers that support content security policy(CSP). This is
            // intentional as we check for the existence of __kbnCspNotEnforced__ in
            // bootstrap.
            window.__kbnCspNotEnforced__ = true;
          `), /*#__PURE__*/_react.default.createElement("script", {
    src: bootstrapScriptUrl
  })));
};

exports.Template = Template;
