export const state = () => ({
  networkInfo: null,
})
export const mutations = {
  setEthersProvider(state, value) {
    console.log('setEthersProvider', value)
    state.ethersProvider = value
  },
  setLaunchInfo(state, payload) {
    state.launchAddress = payload.launchAddress
    state.launchHash = payload.launchHash
  },
  setRecipientInfo(state, payload) {
    state.recipient = payload.recipient
    state.recipientAddress = payload.recipientAddress
  }
}
