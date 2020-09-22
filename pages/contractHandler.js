import Web3 from 'web3'

export default {
  	components: {},
	data() {
		return {
		  abis: {}
		}
	},
	async mounted() {
		await loadAbis()
	},
	methods: {
		async loadAbis() {
			var rawdata = fs.readFileSync('../build/contracts/UserManagement.json')
			let abi = JSON.parse(rawdata)
			abis[UserManagement] = abi
		}
	}
}