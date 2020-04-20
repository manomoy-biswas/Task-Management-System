import consumer from "./consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    console.log("Connected to client")
  },

  disconnected() {
    console.log("Disconnected from client")
  },

  received(data) {
    console.log(data.content)
    $("#unread-count,#unread-count1").text("(" + data.count + ")")
    $("#notifications").prepend(data.content)
  }
});
