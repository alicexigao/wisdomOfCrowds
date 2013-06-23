/**
 * Created with JetBrains WebStorm.
 * User: alicexigao
 * Date: 6/23/13
 * Time: 3:48 PM
 * To change this template use File | Settings | File Templates.
 */

Template.chatRoom.helpers({
    messages: function() {
        return ChatMessages.find();
    }
})