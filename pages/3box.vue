<template>
  <div class="container">
    <div>
      <h1 class="title">
        3Box Tools
      </h1>
      <h2 class="subtitle">
        3Box Integrations
      </h2>
      <div>
          <img
            :src="imageUrl"
            :title="name"
            @click="gowebsite()"
          >
      </div>
    </div>
  </div>
</template>

<script>
import '3box'
export default {
  components: {},
  data() {
    return {
      ethereumAddress: null,
      name: null,
      website: null,
      imageUrl: null
    }
  },
  async mounted() {
  	this.ethereumAddress = this.$route.query.ethereumAddress
  	const Box = require('3box')
  	const profile = await Box.getProfile(this.ethereumAddress)

  	console.log(profile.image[0]['contentUrl'])
  	this.imageUrl = 'https://ipfs.infura.io/ipfs/QmQgkKiQRMpkoQV1Nz6XoEPtn4HpqtFVX73kGzruy2d2CF'
  	this.name = profile.name
  	this.website = profile.website
  },
  methods: {
	gowebsite(){
		if (this.website) {
			window.open('https://'+this.website)
		}
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