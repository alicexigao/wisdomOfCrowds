/**
 * Created with JetBrains WebStorm.
 * User: alicexigao
 * Date: 6/23/13
 * Time: 3:58 PM
 * To change this template use File | Settings | File Templates.
 */

if (ChatMessages.find().count() === 0) {
    ChatMessages.insert({
        author: "AAA",
        content: "Message from AAA"
    });

    ChatMessages.insert({
        author: "BBB",
        content: "Message from BBB"
    });
}