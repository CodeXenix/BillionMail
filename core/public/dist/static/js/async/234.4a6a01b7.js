"use strict";(self.webpackChunkfrontend=self.webpackChunkfrontend||[]).push([["234"],{47399(e,t,a){a.d(t,{FI:()=>m,GA:()=>v,MX:()=>c,VP:()=>p,XZ:()=>s,lC:()=>u,oc:()=>f,p0:()=>h,pS:()=>i,u3:()=>o,vq:()=>d});var r=a(53626),n=a(12189);let{t:l}=r.Ru.global;function o(e){return n.K.get("/batch_mail/task/list",{params:e})}function i(e){return n.K.get("/batch_mail/task/stat_chart",{params:e})}function c(e){return n.K.get("/batch_mail/task/find",{params:e})}function s(e){return n.K.post("/batch_mail/task/create",e,{fetchOptions:{loading:l("market.task.loading.creating"),successMessage:!0}})}function u(e){return n.K.post("/batch_mail/task/update",e,{fetchOptions:{loading:l("market.task.loading.updating"),successMessage:!0}})}function d(e){return n.K.post("/batch_mail/task/delete",e,{fetchOptions:{loading:l("market.task.loading.deleting"),successMessage:!0}})}function v(e){return n.K.post("/batch_mail/task/pause",e,{fetchOptions:{loading:l("market.task.loading.pausing"),successMessage:!0}})}function p(e){return n.K.post("/batch_mail/task/resume",e,{fetchOptions:{loading:l("market.task.loading.resuming"),successMessage:!0}})}function m(e){return n.K.post("/batch_mail/task/send_test",e,{fetchOptions:{loading:l("market.task.loading.sendingTest"),successMessage:!0}})}function h(e){return n.K.get("/batch_mail/tracking/mail_provider",{params:e})}function f(e){return n.K.get("/batch_mail/tracking/logs",{params:e})}},29490(e,t,a){a.r(t),a.d(t,{default:()=>C});var r=a(90655),n=a(98816),l=a(20923),o=a(67083),i=a(32184),c=a(18123),s=a(65340),u=a(47399),d=a(16320),v=a(14476),p=a(96342),m=a(11182),h=a(93648),f=a(71360);let b={class:"p-24px"},k={class:"flex justify-between items-center gap-16px mb-16px"},g={class:"font-bold text-basic"},_={class:"metrics-cards"},y={class:"detail-row"},x={class:"rate-charts-card"},w=(0,c.defineComponent)({__name:"analytics",setup(e){let t=(0,h.t)(),{t:a,locale:w}=(0,f.s9)(),C=(0,c.computed)(()=>(0,s.WZ)(t.params.id||"0")),V=(0,c.ref)((0,s.JZ)()),N=(0,c.ref)([]),B=(0,c.ref)({sends:0,delivered:0,delivery_rate:0,opened:0,open_rate:0,clicked:0,click_rate:0,bounced:0,bounce_rate:0,delayed_queue:0}),$=(0,c.computed)(()=>{let e=B.value;return[{key:"delivery_rate",title:a("overview.delivered"),icon:"i-lucide-mail-check",value:e.delivery_rate,caption:`${e.delivered.toLocaleString(w.value)} / ${e.sends.toLocaleString(w.value)}`},{key:"open_rate",title:a("overview.opened"),icon:"i-lucide-mail-open",value:e.open_rate,caption:`${e.opened.toLocaleString(w.value)} / ${e.delivered.toLocaleString(w.value)}`},{key:"click_rate",title:a("overview.clicked"),icon:"i-lucide-mouse-pointer-click",value:e.click_rate,caption:`${e.clicked.toLocaleString(w.value)} / ${e.delivered.toLocaleString(w.value)}`},{key:"bounce_rate",title:a("overview.bounced"),icon:"i-lucide-mail-warning",value:e.bounce_rate,caption:`${e.bounced.toLocaleString(w.value)} / ${e.sends.toLocaleString(w.value)}`}]}),S=(0,c.ref)({column_type:"hourly",dashboard:{delivered:0,delivery_rate:0,failed:0,failure_rate:0,sends:0},data:[]}),A=(0,c.ref)({column_type:"hourly",data:[]}),E=(0,c.ref)({column_type:"hourly",data:[]}),L=(0,c.ref)({column_type:"hourly",data:[]});async function M(){let e=await (0,u.pS)({task_id:C.value,start_time:Math.floor(V.value[0]/1e3),end_time:Math.floor(V.value[1]/1e3)});(0,s.Gv)(e)&&(B.value=e.dashboard,N.value=(0,s.cy)(e.mail_providers)?e.mail_providers:[],S.value=e.send_mail_chart,A.value=e.bounce_rate_chart,E.value=e.click_rate_chart,L.value=e.open_rate_chart)}let K=(0,c.ref)("");return(async()=>{let e=await (0,u.MX)({id:C.value});(0,s.Gv)(e)&&(K.value=e.subject)})(),(e,t)=>{let a=(0,c.resolveComponent)("router-link"),s=i.A,u=o.Ay,h=l.Ay,f=n.A,w=r.Ay;return(0,c.openBlock)(),(0,c.createElementBlock)("div",b,[(0,c.createElementVNode)("div",k,[(0,c.createVNode)(h,null,{default:(0,c.withCtx)(()=>[(0,c.createVNode)(s,null,{default:(0,c.withCtx)(()=>[(0,c.createVNode)(a,{to:"/market/task"},{default:(0,c.withCtx)(()=>[(0,c.createTextVNode)((0,c.toDisplayString)(e.$t("market.task.title")),1)]),_:1})]),_:1}),(0,c.createVNode)(s,null,{default:(0,c.withCtx)(()=>[(0,c.createTextVNode)((0,c.toDisplayString)(e.$t("market.task.actions.analytics")),1)]),_:1}),(0,c.createVNode)(s,null,{default:(0,c.withCtx)(()=>[(0,c.createVNode)(u,{style:{"max-width":"300px"}},{default:(0,c.withCtx)(()=>[(0,c.createElementVNode)("span",g,(0,c.toDisplayString)((0,c.unref)(K)||"--"),1)]),_:1})]),_:1})]),_:1}),(0,c.createVNode)(f,{value:(0,c.unref)(V),"onUpdate:value":t[0]||(t[0]=e=>(0,c.isRef)(V)?V.value=e:null),"default-type":"last7days",onChange:M},null,8,["value"])]),(0,c.createElementVNode)("div",_,[((0,c.openBlock)(!0),(0,c.createElementBlock)(c.Fragment,null,(0,c.renderList)((0,c.unref)($),e=>((0,c.openBlock)(),(0,c.createBlock)(d.A,{key:e.key,title:e.title,value:e.value,unit:"%",icon:e.icon,caption:e.caption},null,8,["title","value","icon","caption"]))),128))]),(0,c.createElementVNode)("div",y,[(0,c.createVNode)(w,{title:e.$t("overview.mailProviders")},{default:(0,c.withCtx)(()=>[(0,c.createVNode)(v.A,{value:(0,c.unref)(N),"onUpdate:value":t[1]||(t[1]=e=>(0,c.isRef)(N)?N.value=e:null)},null,8,["value"])]),_:1},8,["title"]),(0,c.createVNode)(w,{title:e.$t("overview.sendStats")},{default:(0,c.withCtx)(()=>[(0,c.createVNode)(p.A,{data:(0,c.unref)(S)},null,8,["data"])]),_:1},8,["title"])]),(0,c.createElementVNode)("div",x,[(0,c.createVNode)(m.A,{bounce:(0,c.unref)(A),click:(0,c.unref)(E),open:(0,c.unref)(L)},null,8,["bounce","click","open"])])])}}}),C=(0,a(12194).default)(w,[["__scopeId","data-v-8e784662"]])},20923(e,t,a){a.d(t,{s7:()=>d,Ay:()=>p});var r=a(18123),n=a(12894),l=a(91945),o=a(47580),i=a(98667),c=a(81125),s=a(26005);let u=(0,s.cB)("breadcrumb",`
 white-space: nowrap;
 cursor: default;
 line-height: var(--n-item-line-height);
`,[(0,s.c)("ul",`
 list-style: none;
 padding: 0;
 margin: 0;
 `),(0,s.c)("a",`
 color: inherit;
 text-decoration: inherit;
 `),(0,s.cB)("breadcrumb-item",`
 font-size: var(--n-font-size);
 transition: color .3s var(--n-bezier);
 display: inline-flex;
 align-items: center;
 `,[(0,s.cB)("icon",`
 font-size: 18px;
 vertical-align: -.2em;
 transition: color .3s var(--n-bezier);
 color: var(--n-item-text-color);
 `),(0,s.c)("&:not(:last-child)",[(0,s.cM)("clickable",[(0,s.cE)("link",`
 cursor: pointer;
 `,[(0,s.c)("&:hover",`
 background-color: var(--n-item-color-hover);
 `),(0,s.c)("&:active",`
 background-color: var(--n-item-color-pressed); 
 `)])])]),(0,s.cE)("link",`
 padding: 4px;
 border-radius: var(--n-item-border-radius);
 transition:
 background-color .3s var(--n-bezier),
 color .3s var(--n-bezier);
 color: var(--n-item-text-color);
 position: relative;
 `,[(0,s.c)("&:hover",`
 color: var(--n-item-text-color-hover);
 `,[(0,s.cB)("icon",`
 color: var(--n-item-text-color-hover);
 `)]),(0,s.c)("&:active",`
 color: var(--n-item-text-color-pressed);
 `,[(0,s.cB)("icon",`
 color: var(--n-item-text-color-pressed);
 `)])]),(0,s.cE)("separator",`
 margin: 0 8px;
 color: var(--n-separator-color);
 transition: color .3s var(--n-bezier);
 user-select: none;
 -webkit-user-select: none;
 `),(0,s.c)("&:last-child",[(0,s.cE)("link",`
 font-weight: var(--n-font-weight-active);
 cursor: unset;
 color: var(--n-item-text-color-active);
 `,[(0,s.cB)("icon",`
 color: var(--n-item-text-color-active);
 `)]),(0,s.cE)("separator",`
 display: none;
 `)])])]),d=(0,i.D)("n-breadcrumb"),v=Object.assign(Object.assign({},n.A.props),{separator:{type:String,default:"/"}}),p=(0,r.defineComponent)({name:"Breadcrumb",props:v,setup(e){let{mergedClsPrefixRef:t,inlineThemeDisabled:a}=(0,l.Ay)(e),i=(0,n.A)("Breadcrumb","-breadcrumb",u,c.A,e,t);(0,r.provide)(d,{separatorRef:(0,r.toRef)(e,"separator"),mergedClsPrefixRef:t});let s=(0,r.computed)(()=>{let{common:{cubicBezierEaseInOut:e},self:{separatorColor:t,itemTextColor:a,itemTextColorHover:r,itemTextColorPressed:n,itemTextColorActive:l,fontSize:o,fontWeightActive:c,itemBorderRadius:s,itemColorHover:u,itemColorPressed:d,itemLineHeight:v}}=i.value;return{"--n-font-size":o,"--n-bezier":e,"--n-item-text-color":a,"--n-item-text-color-hover":r,"--n-item-text-color-pressed":n,"--n-item-text-color-active":l,"--n-separator-color":t,"--n-item-color-hover":u,"--n-item-color-pressed":d,"--n-item-border-radius":s,"--n-font-weight-active":c,"--n-item-line-height":v}}),v=a?(0,o.R)("breadcrumb",void 0,s,e):void 0;return{mergedClsPrefix:t,cssVars:a?void 0:s,themeClass:null==v?void 0:v.themeClass,onRender:null==v?void 0:v.onRender}},render(){var e;return null==(e=this.onRender)||e.call(this),(0,r.h)("nav",{class:[`${this.mergedClsPrefix}-breadcrumb`,this.themeClass],style:this.cssVars,"aria-label":"Breadcrumb"},(0,r.h)("ul",null,this.$slots))}})},32184(e,t,a){a.d(t,{A:()=>i});var r=a(18123),n=a(80224),l=a(12221),o=a(20923);let i=(0,r.defineComponent)({name:"BreadcrumbItem",props:{separator:String,href:String,clickable:{type:Boolean,default:!0},onClick:Function},slots:Object,setup(e,{slots:t}){let a=(0,r.inject)(o.s7,null);if(!a)return()=>null;let{separatorRef:i,mergedClsPrefixRef:c}=a,s=function(e=l.B?window:null){let t=()=>{let{hash:t,host:a,hostname:r,href:n,origin:l,pathname:o,port:i,protocol:c,search:s}=(null==e?void 0:e.location)||{};return{hash:t,host:a,hostname:r,href:n,origin:l,pathname:o,port:i,protocol:c,search:s}},a=(0,r.ref)(t()),n=()=>{a.value=t()};return(0,r.onMounted)(()=>{e&&(e.addEventListener("popstate",n),e.addEventListener("hashchange",n))}),(0,r.onUnmounted)(()=>{e&&(e.removeEventListener("popstate",n),e.removeEventListener("hashchange",n))}),a}(),u=(0,r.computed)(()=>e.href?"a":"span"),d=(0,r.computed)(()=>s.value.href===e.href?"location":null);return()=>{let{value:a}=c;return(0,r.h)("li",{class:[`${a}-breadcrumb-item`,e.clickable&&`${a}-breadcrumb-item--clickable`]},(0,r.h)(u.value,{class:`${a}-breadcrumb-item__link`,"aria-current":d.value,href:e.href,onClick:e.onClick},t),(0,r.h)("span",{class:`${a}-breadcrumb-item__separator`,"aria-hidden":"true"},(0,n.Nj)(t.separator,()=>{var t;return[null!=(t=e.separator)?t:i.value]})))}}})}}]);