!function(e){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=e();else if("function"==typeof define&&define.amd)define([],e);else{("undefined"!=typeof window?window:"undefined"!=typeof global?global:"undefined"!=typeof self?self:this).markdownItTocDoneRight=e()}}((function(){return function e(n,r,t){function o(l,s){if(!r[l]){if(!n[l]){var c="function"==typeof require&&require;if(!s&&c)return c(l,!0);if(i)return i(l,!0);var a=new Error("Cannot find module '"+l+"'");throw a.code="MODULE_NOT_FOUND",a}var u=r[l]={exports:{}};n[l][0].call(u.exports,(function(e){return o(n[l][1][e]||e)}),u,u.exports,e,n,r,t)}return r[l].exports}for(var i="function"==typeof require&&require,l=0;l<t.length;l++)o(t[l]);return o}({1:[function(e,n,r){function t(e){return encodeURIComponent(String(e).trim().toLowerCase().replace(/\s+/g,"-"))}function o(e){return String(e).replace(/&/g,"&amp;").replace(/"/g,"&quot;").replace(/'/g,"&#39;").replace(/</g,"&lt;").replace(/>/g,"&gt;")}n.exports=function(e,n){var r;n=Object.assign({},{placeholder:"(\\$\\{toc\\}|\\[\\[?_?toc_?\\]?\\]|\\$\\<toc(\\{[^}]*\\})\\>)",slugify:t,containerClass:"table-of-contents",containerId:void 0,listClass:void 0,itemClass:void 0,linkClass:void 0,level:1,listType:"ol",format:void 0,callback:void 0},n);var i=new RegExp("^"+n.placeholder+"$","i");e.renderer.rules.tocOpen=function(e,r){var t=Object.assign({},n);return e&&r>=0&&(t=Object.assign(t,e[r].inlineOptions)),"<nav"+(t.containerId?' id="'+o(t.containerId)+'"':"")+' class="'+o(t.containerClass)+'">'},e.renderer.rules.tocClose=function(){return"</nav>"},e.renderer.rules.tocBody=function(e,t){var i=Object.assign({},n);e&&t>=0&&(i=Object.assign(i,e[t].inlineOptions));var l,s={},c=Array.isArray(i.level)?(l=i.level,function(e){return l.includes(e)}):function(e){return function(n){return n>=e}}(i.level);return function e(r){var t=i.listClass?' class="'+o(i.listClass)+'"':"",l=i.itemClass?' class="'+o(i.itemClass)+'"':"",a=i.linkClass?' class="'+o(i.linkClass)+'"':"";if(0===r.c.length)return"";var u="";return(0===r.l||c(r.l))&&(u+="<"+(o(i.listType)+t)+">"),r.c.forEach((function(r){c(r.l)?u+="<li"+l+"><a"+a+' href="#'+function(e){for(var n=e,r=2;Object.prototype.hasOwnProperty.call(s,n);)n=e+"-"+r++;return s[n]=!0,n}(n.slugify(r.n))+'">'+("function"==typeof i.format?i.format(r.n,o):o(r.n))+"</a>"+e(r)+"</li>":u+=e(r)})),(0===r.l||c(r.l))&&(u+="</"+o(i.listType)+">"),u}(r)},e.core.ruler.push("generateTocAst",(function(t){r=function(e){for(var n={l:0,n:"",c:[]},r=[n],t=0,o=e.length;t<o;t++){var i=e[t];if("heading_open"===i.type){var l=e[t+1].children.filter((function(e){return"text"===e.type||"code_inline"===e.type})).reduce((function(e,n){return e+n.content}),""),s={l:parseInt(i.tag.substr(1),10),n:l,c:[]};if(s.l>r[0].l)r[0].c.push(s),r.unshift(s);else if(s.l===r[0].l)r[1].c.push(s),r[0]=s;else{for(;s.l<=r[0].l;)r.shift();r[0].c.push(s),r.unshift(s)}}}return n}(t.tokens),"function"==typeof n.callback&&n.callback(e.renderer.rules.tocOpen()+e.renderer.rules.tocBody()+e.renderer.rules.tocClose(),r)})),e.block.ruler.before("heading","toc",(function(e,n,r,t){var o,l=e.src.slice(e.bMarks[n]+e.tShift[n],e.eMarks[n]).split(" ")[0];if(!i.test(l))return!1;if(t)return!0;var s=i.exec(l),c={};if(null!==s&&3===s.length)try{c=JSON.parse(s[2])}catch(e){}return e.line=n+1,(o=e.push("tocOpen","nav",1)).markup="",o.map=[n,e.line],o.inlineOptions=c,(o=e.push("tocBody","",0)).markup="",o.map=[n,e.line],o.inlineOptions=c,o.children=[],(o=e.push("tocClose","nav",-1)).markup="",!0}),{alt:["paragraph","reference","blockquote"]})}},{}]},{},[1])(1)}));