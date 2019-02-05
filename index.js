const Koa = require('koa')
const Router = require('koa-router')

const app = (module.exports = new Koa())

const router = new Router()

router.get('/health', ctx => {
  ctx.body = { status: 'ice cream service is on!' }
})

router.get('/', ctx => {
  ctx.body = { message: 'Welcome to the ice cream service!' }
})

router.get('/vanilla', ctx => {
  ctx.body = { flavor: 'vanilla' }
})

app.use(router.routes()).use(router.allowedMethods())

console.log('Starting Koa server on port 8000')
if (!module.parent) app.listen(8000)
