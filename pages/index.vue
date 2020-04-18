<template>
  <div class="container">
    <div>
      <h1 class="title">
        Web3 Tools
      </h1>
      <h2 class="subtitle">
        Fundamental tools for interacting in web3
      </h2>
      <div class="links">
        <a
          @click="go3Box(ethereumAddress)"
          target="_blank"
          class="button--green"
        >
          3Box Tools
        </a>
        <a
          @click="goFactory()"
          target="_blank"
          class="button--grey"
        >
          Contract Factory
        </a>
      </div>
    </div>
  </div>
</template>

<script>
import MetamaskHandler from "./metamaskHandler"
export default {
  extends: MetamaskHandler,
  components: {},
  data() {
    return {
      ethereumAddress: null
    }
  },
  async mounted() {
    this.ready = true
  },
  methods: {
    go3Box (ethereumAddress){
      this.$router.push({ name: '3box', query: { ethereumAddress: ethereumAddress } })
    },
    goFactory (){
      this.$router.push({ name: 'contractFactory'})
    }
  }
}
</script>

<style>
.container {
  margin: 0 auto;
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
}

.title {
  font-family: 'Quicksand', 'Source Sans Pro', -apple-system, BlinkMacSystemFont,
    'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  display: block;
  font-weight: 300;
  font-size: 100px;
  color: #35495e;
  letter-spacing: 1px;
}

.subtitle {
  font-weight: 300;
  font-size: 42px;
  color: #526488;
  word-spacing: 5px;
  padding-bottom: 15px;
}

.links {
  padding-top: 15px;
}
</style>
