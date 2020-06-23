import Vue from 'vue'
import Router from 'vue-router'
import { interopDefault } from './utils'
import scrollBehavior from './router.scrollBehavior.js'

const _37e75a8b = () => interopDefault(import('../pages/3box.vue' /* webpackChunkName: "pages/3box" */))
const _1a4bc62d = () => interopDefault(import('../pages/DepositContract.vue' /* webpackChunkName: "pages/DepositContract" */))
const _77d4aab6 = () => interopDefault(import('../pages/ERC1155Contract.vue' /* webpackChunkName: "pages/ERC1155Contract" */))
const _d988f652 = () => interopDefault(import('../pages/ERC20ContractFactory.vue' /* webpackChunkName: "pages/ERC20ContractFactory" */))
const _39a74875 = () => interopDefault(import('../pages/ERC721ContractFactory.vue' /* webpackChunkName: "pages/ERC721ContractFactory" */))
const _9e24be88 = () => interopDefault(import('../pages/ManagerContract.vue' /* webpackChunkName: "pages/ManagerContract" */))
const _327d0539 = () => interopDefault(import('../pages/metamaskHandler.js' /* webpackChunkName: "pages/metamaskHandler" */))
const _7facefa1 = () => interopDefault(import('../pages/ValidatorContract.vue' /* webpackChunkName: "pages/ValidatorContract" */))
const _f0ba1ae2 = () => interopDefault(import('../pages/index.vue' /* webpackChunkName: "pages/index" */))

// TODO: remove in Nuxt 3
const emptyFn = () => {}
const originalPush = Router.prototype.push
Router.prototype.push = function push (location, onComplete = emptyFn, onAbort) {
  return originalPush.call(this, location, onComplete, onAbort)
}

Vue.use(Router)

export const routerOptions = {
  mode: 'history',
  base: decodeURI('/'),
  linkActiveClass: 'nuxt-link-active',
  linkExactActiveClass: 'nuxt-link-exact-active',
  scrollBehavior,

  routes: [{
    path: "/3box",
    component: _37e75a8b,
    name: "3box"
  }, {
    path: "/DepositContract",
    component: _1a4bc62d,
    name: "DepositContract"
  }, {
    path: "/ERC1155Contract",
    component: _77d4aab6,
    name: "ERC1155Contract"
  }, {
    path: "/ERC20ContractFactory",
    component: _d988f652,
    name: "ERC20ContractFactory"
  }, {
    path: "/ERC721ContractFactory",
    component: _39a74875,
    name: "ERC721ContractFactory"
  }, {
    path: "/ManagerContract",
    component: _9e24be88,
    name: "ManagerContract"
  }, {
    path: "/metamaskHandler",
    component: _327d0539,
    name: "metamaskHandler"
  }, {
    path: "/ValidatorContract",
    component: _7facefa1,
    name: "ValidatorContract"
  }, {
    path: "/",
    component: _f0ba1ae2,
    name: "index"
  }],

  fallback: false
}

export function createRouter () {
  return new Router(routerOptions)
}
