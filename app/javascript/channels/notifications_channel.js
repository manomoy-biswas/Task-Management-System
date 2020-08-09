import consumer from "./consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
  },

  disconnected() {
  },

  received(data) {
    console.log(data.content)
    $("#unread_count,#unread_count1").text(data.count)
    $("#notifications").prepend(data.content)
  }
});
