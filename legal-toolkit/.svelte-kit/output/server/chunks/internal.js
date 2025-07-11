import{H as w,g as D,d as I,s as P,a as N,i as F,b as T,c as U,e as R,f as Y,C as L,h as V,j as G,k as W,l as J,m as K,n as Q,o as X,p as Z,q as $,r as tt,t as et,u as nt,L as st,v as M,w as rt,x as at,y as it,z as ot,A as lt,D as ct}from"./index.js";import"clsx";let k="",S=k;const Ct="_app",E={base:k,assets:S};function Tt(t){k=t.base,S=t.assets}function Pt(){k=E.base,S=E.assets}function Nt(t){S=E.assets=t}let ut={},dt={};function Lt(t){}function Mt(t){ut=t}function At(t){dt=t}function q(t){console.warn("https://svelte.dev/e/hydration_mismatch")}let x=!1;function y(t){x=t}let m;function O(t){if(t===null)throw q(),w;return m=t}function ft(){return O(D(m))}const ht=["touchstart","touchmove"];function _t(t){return ht.includes(t)}const mt=new Set,A=new Set;function b(t){var e=this,r=e.ownerDocument,i=t.type,a=t.composedPath?.()||[],n=a[0]||t.target,s=0,o=t.__root;if(o){var d=a.indexOf(o);if(d!==-1&&(e===document||e===window)){t.__root=e;return}var f=a.indexOf(e);if(f===-1)return;d<=f&&(s=d)}if(n=a[s]||t.target,n!==e){I(t,"currentTarget",{configurable:!0,get(){return n||r}});var h=U,c=T;P(null),N(null);try{for(var l,u=[];n!==null;){var g=n.assignedSlot||n.parentNode||n.host||null;try{var _=n["__"+i];if(_!=null&&(!n.disabled||t.target===n))if(F(_)){var[z,...B]=_;z.apply(n,[t,...B])}else _.call(n,t)}catch(p){l?u.push(p):l=p}if(t.cancelBubble||g===e||g===null)break;n=g}if(l){for(let p of u)queueMicrotask(()=>{throw p});throw l}}finally{t.__root=e,delete t.currentTarget,P(h),N(c)}}}function gt(t,e){var r=T;r.nodes_start===null&&(r.nodes_start=t,r.nodes_end=e)}function j(t,e){return H(t,e)}function vt(t,e){R(),e.intro=e.intro??!1;const r=e.target,i=x,a=m;try{for(var n=Y(r);n&&(n.nodeType!==L||n.data!==V);)n=D(n);if(!n)throw w;y(!0),O(n),ft();const s=H(t,{...e,anchor:n});if(m===null||m.nodeType!==L||m.data!==G)throw q(),w;return y(!1),s}catch(s){if(s===w)return e.recover===!1&&W(),R(),J(r),y(!1),j(t,e);throw s}finally{y(i),O(a)}}const v=new Map;function H(t,{target:e,anchor:r,props:i={},events:a,context:n,intro:s=!0}){R();var o=new Set,d=c=>{for(var l=0;l<c.length;l++){var u=c[l];if(!o.has(u)){o.add(u);var g=_t(u);e.addEventListener(u,b,{passive:g});var _=v.get(u);_===void 0?(document.addEventListener(u,b,{passive:g}),v.set(u,1)):v.set(u,_+1)}}};d(K(mt)),A.add(d);var f=void 0,h=Q(()=>{var c=r??e.appendChild(X());return Z(()=>{if(n){$({});var l=tt;l.c=n}a&&(i.$$events=a),x&&gt(c,null),f=t(c,i)||{},x&&(T.nodes_end=m),n&&et()}),()=>{for(var l of o){e.removeEventListener(l,b);var u=v.get(l);--u===0?(document.removeEventListener(l,b),v.delete(l)):v.set(l,u)}A.delete(d),c!==r&&c.parentNode?.removeChild(c)}});return C.set(f,h),f}let C=new WeakMap;function pt(t,e){const r=C.get(t);return r?(C.delete(t),r(e)):Promise.resolve()}function yt(t){return class extends bt{constructor(e){super({component:t,...e})}}}class bt{#e;#t;constructor(e){var r=new Map,i=(n,s)=>{var o=at(s,!1,!1);return r.set(n,o),o};const a=new Proxy({...e.props||{},$$events:{}},{get(n,s){return M(r.get(s)??i(s,Reflect.get(n,s)))},has(n,s){return s===st?!0:(M(r.get(s)??i(s,Reflect.get(n,s))),Reflect.has(n,s))},set(n,s,o){return nt(r.get(s)??i(s,o),o),Reflect.set(n,s,o)}});this.#t=(e.hydrate?vt:j)(e.component,{target:e.target,anchor:e.anchor,props:a,context:e.context,intro:e.intro??!1,recover:e.recover}),(!e?.props?.$$host||e.sync===!1)&&rt(),this.#e=a.$$events;for(const n of Object.keys(this.#t))n==="$set"||n==="$destroy"||n==="$on"||I(this,n,{get(){return this.#t[n]},set(s){this.#t[n]=s},enumerable:!0});this.#t.$set=n=>{Object.assign(a,n)},this.#t.$destroy=()=>{pt(this.#t)}}$set(e){this.#t.$set(e)}$on(e,r){this.#e[e]=this.#e[e]||[];const i=(...a)=>r.call(this,...a);return this.#e[e].push(i),()=>{this.#e[e]=this.#e[e].filter(a=>a!==i)}}$destroy(){this.#t.$destroy()}}let wt=null;function Dt(t){wt=t}function It(t){}function xt(t){const e=yt(t),r=(i,{context:a}={})=>{const n=it(t,{props:i,context:a});return{css:{code:"",map:null},head:n.head,html:n.body}};return e.render=r,e}let kt=!1;function qt(){}function jt(){kt=!0}function St(t,e){ot();let{stores:r,page:i,constructors:a,components:n=[],form:s,data_0:o=null,data_1:d=null}=e;lt("__svelte__",r),r.page.set(i);const f=a[1];if(a[1]){t.out+="<!--[-->";const h=a[0];t.out+="<!---->",h(t,{data:o,form:s,children:c=>{c.out+="<!---->",f(c,{data:d,form:s}),c.out+="<!---->"},$$slots:{default:!0}}),t.out+="<!---->"}else{t.out+="<!--[!-->";const h=a[0];t.out+="<!---->",h(t,{data:o,form:s}),t.out+="<!---->"}t.out+="<!--]--> ",t.out+="<!--[!-->",t.out+="<!--]-->",ct()}const Rt=xt(St),Ht={app_template_contains_nonce:!1,csp:{mode:"auto",directives:{"upgrade-insecure-requests":!1,"block-all-mixed-content":!1},reportOnly:{"upgrade-insecure-requests":!1,"block-all-mixed-content":!1}},csrf_check_origin:!0,embedded:!1,env_public_prefix:"PUBLIC_",env_private_prefix:"",hash_routing:!1,hooks:null,preload_strategy:"modulepreload",root:Rt,service_worker:!1,templates:{app:({head:t,body:e,assets:r,nonce:i,env:a})=>`<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Legal Toolkit</title>
    <meta name="description" content="Privacy-first legal case management toolkit" />
    
    `+t+`
    
    <style>
      body {
        margin: 0;
        padding: 0;
        background: #f8f9fa;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      }
      
      * {
        box-sizing: border-box;
      }
    </style>
  </head>
  <body data-sveltekit-preload-data="hover">
    <div style="display: contents">`+e+`</div>
  </body>
</html>`,error:({status:t,message:e})=>`<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>`+e+`</title>

		<style>
			body {
				--bg: white;
				--fg: #222;
				--divider: #ccc;
				background: var(--bg);
				color: var(--fg);
				font-family:
					system-ui,
					-apple-system,
					BlinkMacSystemFont,
					'Segoe UI',
					Roboto,
					Oxygen,
					Ubuntu,
					Cantarell,
					'Open Sans',
					'Helvetica Neue',
					sans-serif;
				display: flex;
				align-items: center;
				justify-content: center;
				height: 100vh;
				margin: 0;
			}

			.error {
				display: flex;
				align-items: center;
				max-width: 32rem;
				margin: 0 1rem;
			}

			.status {
				font-weight: 200;
				font-size: 3rem;
				line-height: 1;
				position: relative;
				top: -0.05rem;
			}

			.message {
				border-left: 1px solid var(--divider);
				padding: 0 0 0 1rem;
				margin: 0 0 0 1rem;
				min-height: 2.5rem;
				display: flex;
				align-items: center;
			}

			.message h1 {
				font-weight: 400;
				font-size: 1em;
				margin: 0;
			}

			@media (prefers-color-scheme: dark) {
				body {
					--bg: #222;
					--fg: #ddd;
					--divider: #666;
				}
			}
		</style>
	</head>
	<body>
		<div class="error">
			<span class="status">`+t+`</span>
			<div class="message">
				<h1>`+e+`</h1>
			</div>
		</div>
	</body>
</html>
`},version_hash:"1vsq8or"};async function zt(){return{handle:void 0,handleFetch:void 0,handleError:void 0,init:void 0,reroute:void 0,transport:void 0}}export{S as a,k as b,Ct as c,wt as d,Ht as e,Lt as f,zt as g,kt as h,Mt as i,At as j,Dt as k,Nt as l,qt as m,It as n,Tt as o,ut as p,jt as q,Pt as r,dt as s};
