import consumer from "./consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected to client")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("Disconnected from client")
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log("Receiving...")
    console.log(data.content)
    $("#unread-count,#unread-count1").text("(" + data.count + ")")
    $("#notifications").prepend("<a class=\"dropdown-item\" href=\"/" + data.task_id.to_s + "\" value=\"" + data.task_id.to_s + "\">" + data.content + "</a>")
  }
});
