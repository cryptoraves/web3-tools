import Web3 from 'web3'
import {fs} from 'fs'

export default {
  	components: {},
	data() {
		return {
		  ethereumAddress: null,
		  networkType: null
		}
	},
	async mounted() {
		var output = fs.readFileSync('../build/contracts/UserManagement.json')

		console.log(output)
	},
	methods: {
		async init() {
		}
	}
}