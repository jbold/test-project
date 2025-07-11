export const manifest = (() => {
function __memo(fn) {
	let value;
	return () => value ??= (value = fn());
}

return {
	appDir: "_app",
	appPath: "_app",
	assets: new Set([]),
	mimeTypes: {},
	_: {
		client: {start:"_app/immutable/entry/start.CGABRHjl.js",app:"_app/immutable/entry/app.Cg-6MLFJ.js",imports:["_app/immutable/entry/start.CGABRHjl.js","_app/immutable/chunks/C_0RVi1S.js","_app/immutable/chunks/CMYBUtCa.js","_app/immutable/entry/app.Cg-6MLFJ.js","_app/immutable/chunks/CMYBUtCa.js","_app/immutable/chunks/BbkoyQuY.js","_app/immutable/chunks/DT-uLrhF.js"],stylesheets:[],fonts:[],uses_env_dynamic_public:false},
		nodes: [
			__memo(() => import('./nodes/0.js')),
			__memo(() => import('./nodes/1.js')),
			__memo(() => import('./nodes/2.js'))
		],
		routes: [
			{
				id: "/",
				pattern: /^\/$/,
				params: [],
				page: { layouts: [0,], errors: [1,], leaf: 2 },
				endpoint: null
			}
		],
		prerendered_routes: new Set([]),
		matchers: async () => {
			
			return {  };
		},
		server_assets: {}
	}
}
})();
