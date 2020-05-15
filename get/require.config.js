var require = {
  baseUrl: '/lib',
  xxpaths: { 'katex': 'katex/katex' },
  paths: { 'jquery': 'jquery.6ad657dafdfaa495' },
  shim: { 'markdown-it-katex.689b2993b1958946': ['katex.9460c91fb69cca2c'] },
  map: { '*': {
    'codemirror/mode/apl/apl':'codemirror/mode/apl/apl.71cadc768dcd17aa',
    'codemirror/mode/clike/clike':'codemirror/mode/clike/clike.215e8d258f779286',
    'codemirror/mode/clojure/clojure':'codemirror/mode/clojure/clojure.a6c82719a8589569',
    'codemirror/mode/css/css':'codemirror/mode/css/css.4bc27114a047458b',
    'codemirror/mode/erlang/erlang':'codemirror/mode/erlang/erlang.6c840b08e44b804c',
    'codemirror/mode/gfm/gfm':'codemirror/mode/gfm/gfm.f4ad694c46ec6bf6',
    'codemirror/mode/go/go':'codemirror/mode/go/go.2284d5e1ed99bb70',
    'codemirror/mode/haskell/haskell':'codemirror/mode/haskell/haskell.89003d648807d629',
    'codemirror/mode/htmlmixed/htmlmixed':'codemirror/mode/htmlmixed/htmlmixed.e437c7b25be942af',
    'codemirror/mode/javascript/javascript':'codemirror/mode/javascript/javascript.dba573ca58fe9f89',
    'codemirror/mode/julia/julia':'codemirror/mode/julia/julia.9737225b3d556bc5',
    'codemirror/mode/lua/lua':'codemirror/mode/lua/lua.46bed41a163ab8e9',
    'codemirror/mode/markdown/markdown':'codemirror/mode/markdown/markdown.f16af13ece31ce59',
    'codemirror/mode/mllike/mllike':'codemirror/mode/mllike/mllike.3db74901aefde9b7',
    'codemirror/mode/php/php':'codemirror/mode/php/php.8ec12a115955dbe9',
    'codemirror/mode/powershell/powershell':'codemirror/mode/powershell/powershell.0ec3665715de1320',
    'codemirror/mode/python/python':'codemirror/mode/python/python.db2fe31b948160d0',
    'codemirror/mode/shell/shell':'codemirror/mode/shell/shell.5980b96325aa589a',
    'codemirror/mode/sql/sql':'codemirror/mode/sql/sql.c24d05289711c73a',
    'codemirror/mode/stex/stex':'codemirror/mode/stex/stex.bb1677e80c8f487f',
    'codemirror/mode/vb/vb':'codemirror/mode/vb/vb.6a7b7d044ba746e1',
    'codemirror/mode/xml/xml':'codemirror/mode/xml/xml.1d35c14cae46a93b',
    'codemirror/mode/apl':'codemirror/mode/apl.71cadc768dcd17aa',
    'codemirror/mode/clike':'codemirror/mode/clike.215e8d258f779286',
    'codemirror/mode/clojure':'codemirror/mode/clojure.a6c82719a8589569',
    'codemirror/mode/css':'codemirror/mode/css.4bc27114a047458b',
    'codemirror/mode/erlang':'codemirror/mode/erlang.6c840b08e44b804c',
    'codemirror/mode/gfm':'codemirror/mode/gfm.f4ad694c46ec6bf6',
    'codemirror/mode/go':'codemirror/mode/go.2284d5e1ed99bb70',
    'codemirror/mode/haskell':'codemirror/mode/haskell.89003d648807d629',
    'codemirror/mode/htmlmixed':'codemirror/mode/htmlmixed.e437c7b25be942af',
    'codemirror/mode/javascript':'codemirror/mode/javascript.dba573ca58fe9f89',
    'codemirror/mode/julia':'codemirror/mode/julia.9737225b3d556bc5',
    'codemirror/mode/lua':'codemirror/mode/lua.46bed41a163ab8e9',
    'codemirror/mode/markdown':'codemirror/mode/markdown.f16af13ece31ce59',
    'codemirror/mode/mllike':'codemirror/mode/mllike.3db74901aefde9b7',
    'codemirror/mode/php':'codemirror/mode/php.8ec12a115955dbe9',
    'codemirror/mode/powershell':'codemirror/mode/powershell.0ec3665715de1320',
    'codemirror/mode/python':'codemirror/mode/python.db2fe31b948160d0',
    'codemirror/mode/shell':'codemirror/mode/shell.5980b96325aa589a',
    'codemirror/mode/sql':'codemirror/mode/sql.c24d05289711c73a',
    'codemirror/mode/stex':'codemirror/mode/stex.bb1677e80c8f487f',
    'codemirror/mode/vb':'codemirror/mode/vb.6a7b7d044ba746e1',
    'codemirror/mode/xml':'codemirror/mode/xml.1d35c14cae46a93b',
    'codemirror/mode/meta':'codemirror/mode/meta.b3427edc59ba76e6',
    'codemirror/lib/codemirror':'codemirror/lib/codemirror.c55cac653c01cf72',
    'codemirror/addon/runmode/runmode':'codemirror/addon/runmode/runmode.5017e8810200ecd7',
    'codemirror/addon/runmode/colorize':'codemirror/addon/runmode/colorize.e507e083560a8285',
    'codemirror/addon/display/placeholder':'codemirror/addon/display/placeholder.c2412da7adc816c2',
    'codemirror/addon/mode/overlay':'codemirror/addon/mode/overlay.78008086f33a69da',
    'codemirror/codemirror':'codemirror/codemirror.c55cac653c01cf72',
    'codemirror/colorize':'codemirror/colorize.e507e083560a8285',
    'codemirror/runmode':'codemirror/runmode.5017e8810200ecd7',
    'codemirror/placeholder':'codemirror/placeholder.c2412da7adc816c2',
    'jquery.waitforimages':'jquery.waitforimages.ddbd1d428d6bff75',
    'js.cookie':'js.cookie.76935a70978b8098',
    'lodash':'lodash.0205cae71b99e29f',
    'mark':'mark.9c62caf8b13d1f17',
    'markdown-it-abbr':'markdown-it-abbr.a4c1600fcf93c532',
    'markdown-it-container':'markdown-it-container.6bfec73d44d83f3e',
    'markdown-it-deflist':'markdown-it-deflist.0fe834f8e98e50e6',
    'markdown-it-emoji':'markdown-it-emoji.2ef729f133487489',
    'markdown-it-footnote':'markdown-it-footnote.f603b2eba24d2be8',
    'markdown-it-for-inline':'markdown-it-for-inline.616d95e2e481616e',
    'markdown-it-inject-linenumbers':'markdown-it-inject-linenumbers.fe3172e46dc4a28c',
    'markdown-it-sub':'markdown-it-sub.8ed862af30f8d49f',
    'markdown-it-sup':'markdown-it-sup.8954ee74136fd1ee',
    'markdown-it':'markdown-it.423da6f97e0b5f53',
    'moment':'moment.cbe417c063543c63',
    'select2':'select2.6b983cad5301a9a7',
    'katex/contrib/auto-render':'katex/contrib/auto-render.1ce34da626dec02d',
    'katex/contrib/auto-render.min':'katex/contrib/auto-render.min.fd15df9601dcbc09',
    'katex/contrib/copy-tex':'katex/contrib/copy-tex.ca16c1a43dc149ee',
    'katex/contrib/copy-tex.min':'katex/contrib/copy-tex.min.84778a57ce5caa43',
    'katex/contrib/mathtex-script-type':'katex/contrib/mathtex-script-type.a8cd01e76bd7e7c5',
    'katex/contrib/mathtex-script-type.min':'katex/contrib/mathtex-script-type.min.621dd38f63242304',
    'katex/contrib/mhchem':'katex/contrib/mhchem.3707af344f159c31',
    'katex/contrib/mhchem.min':'katex/contrib/mhchem.min.f4b31a8f40f5f252',
    'katex/contrib/render-a11y-string':'katex/contrib/render-a11y-string.dc25a24aba8785d9',
    'katex/contrib/render-a11y-string.min':'katex/contrib/render-a11y-string.min.069ba3c7e1b26dc3',
    'katex/katex':'katex/katex.9460c91fb69cca2c',
    'katex/katex.min':'katex/katex.min.9460c91fb69cca2c',
    'qp/qp':'qp/qp.1eebf353313a8d4c',
    'qp/qp.min':'qp/qp.min.1eebf353313a8d4c',
    'diff_match_patch':'diff_match_patch.6e3838c0996f1453',
    'jquery-3.4.1.min':'jquery-3.4.1.min.6ad657dafdfaa495',
    'jquery.mark.min':'jquery.mark.min.9c62caf8b13d1f17',
    'jquery.simplePagination':'jquery.simplePagination.b892c57d7f01a4e5',
    'jquery.waitforimages.min':'jquery.waitforimages.min.ddbd1d428d6bff75',
    'js.cookie-2.2.1.min':'js.cookie-2.2.1.min.76935a70978b8098',
    'lodash.min':'lodash.min.0205cae71b99e29f',
    'markdown-it-abbr.min':'markdown-it-abbr.min.a4c1600fcf93c532',
    'markdown-it-container.min':'markdown-it-container.min.6bfec73d44d83f3e',
    'markdown-it-deflist.min':'markdown-it-deflist.min.0fe834f8e98e50e6',
    'markdown-it-emoji.min':'markdown-it-emoji.min.2ef729f133487489',
    'markdown-it-footnote.min':'markdown-it-footnote.min.f603b2eba24d2be8',
    'markdown-it-for-inline.min':'markdown-it-for-inline.min.616d95e2e481616e',
    'markdown-it-inject-linenumbers.min':'markdown-it-inject-linenumbers.min.fe3172e46dc4a28c',
    'markdown-it-object':'markdown-it-object.91bf7e1de64af714',
    'markdown-it-sub.min':'markdown-it-sub.min.8ed862af30f8d49f',
    'markdown-it-sup.min':'markdown-it-sup.min.8954ee74136fd1ee',
    'markdown-it.min':'markdown-it.min.423da6f97e0b5f53',
    'markdownItAnchor':'markdownItAnchor.ae40bc8d4a7ecab4',
    'markdownItTocDoneRight':'markdownItTocDoneRight.022f622633419583',
    'moment-with-locales.min':'moment-with-locales.min.cbe417c063543c63',
    'paste':'paste.6bcdb4817596af13',
    'promise-all-settled':'promise-all-settled.b9101ad6b2a74f8b',
    'resizer':'resizer.acc48d85f03977b4',
    'select2.full.min':'select2.full.min.6b983cad5301a9a7',
    'starrr':'starrr.a95baf4870cd4d81',
    'clipboard.min':'clipboard.min.fa1eb95558c72c3f',
    'clipboard':'clipboard.fa1eb95558c72c3f',
    'pako.min':'pako.min.3949f219f23162d4',
    'pako':'pako.3949f219f23162d4',
    'markdown-it-codeinput':'markdown-it-codeinput.6e23d1bd71ea9555',
    'require':'require.04ef68a65b54ab49',
    'markdown-it-katex':'markdown-it-katex.689b2993b1958946',
    'katex':'katex.9460c91fb69cca2c',
    'tio':'../tio.0984e7f3a524834f',
    'navigation':'../navigation.c546209755df730d',
    'markdown':'../markdown.86706dd2b49a3dca',
    'require.config':'../require.config.f5df3c9ca5ed5f71',
 } },
};