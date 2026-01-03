const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Trigger: When a new document is created in 'orders' collection
exports.sendNewOrderNotification = functions.firestore
    .document('orders/{orderId}')
    .onCreate(async (snap, context) => {

        // 1. Get Order Data
        const order = snap.data();
        const orderId = context.params.orderId;
        const farmerId = order.farmerId;

        console.log(`📦 New Order Detected: ${orderId} for Farmer: ${farmerId}`);

        if (!farmerId) {
            console.log('⚠️ No farmerId in order.');
            return;
        }

        try {
            // 2. Fetch Farmer's FCM Token from 'users' collection
            const farmerDoc = await admin.firestore().collection('users').doc(farmerId).get();

            if (!farmerDoc.exists) {
                console.log(`⚠️ Farmer user document ${farmerId} not found.`);
                return;
            }

            const farmerData = farmerDoc.data();
            const fcmToken = farmerData.fcmToken;

            if (!fcmToken) {
                console.log(`⚠️ No FCM Token found for farmer ${farmerId} in their user profile.`);
                return;
            }

            // 3. Construct Notification Payload
            const payload = {
                token: fcmToken,
                notification: {
                    title: 'New Order Received! 🚜',
                    body: `You have a new order from ${order.buyerName || 'a buyer'} for ₹${order.totalAmount || 0}.`,
                },
                data: {
                    type: 'order',
                    orderId: orderId,
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                },
                android: {
                    priority: 'high',
                    notification: {
                        channelId: 'farmigo_channel_id', // Must match AndroidManifest/LocalNotification channel
                    }
                }
            };

            // 4. Send Message via FCM
            const response = await admin.messaging().send(payload);
            console.log('✅ Successfully sent message:', response);

        } catch (error) {
            console.error('❌ Error sending notification:', error);
        }
    });
