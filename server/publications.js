/**
 * Created with JetBrains WebStorm.
 * User: alicexigao
 * Date: 6/23/13
 * Time: 4:02 PM
 * To change this template use File | Settings | File Templates.
 */

Meteor.publish('chatMessages', function() {
    return ChatMessages.find();
})