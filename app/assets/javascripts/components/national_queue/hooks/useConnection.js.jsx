 // external callback (from Queue manager: queue.coffee)
//  const connected() {
//   this.setState({connected: true});
//   // It's not an initial connect, but a retry. Let's refetch queue state!
//   if (this.state.disconnects > 0) {
//     window.App.queue.fetch();
//   }
// }

// // external callback (from Queue manager: queue.coffee)
// const disconnected() {
//   this.setState({
//     disconnects: this.state.disconnects + 1,
//     connected: false
//   });
// }

// // external callback (from Queue manager: queue.coffee)
// const updateData(data) {
//   const state = Object.assign({}, data, { refreshing: false });
//   this.setState(state)
// }

// const hardRefresh = () => {
//   if (this.state.refreshing) return;
//   this.setState({ refreshing: true });
//   window.App.queue.fetch(true);
// }