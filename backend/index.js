const admin = require('firebase-admin');

// 1. Initialize Firebase Admin SDK
// Ideally, you should put your serviceAccountKey.json in this same folder.
try {
  const serviceAccount = require('./serviceAccountKey.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log("✅ Firebase Admin initialized successfully!");
} catch (error) {
  console.error("❌ Error initializing Firebase Admin. Did you add serviceAccountKey.json?");
  console.error(error.message);
  process.exit(1);
}

const db = admin.firestore();
const messaging = admin.messaging();

console.log("🚀 Farmigo Notification Backend is running...");
console.log("🎧 Listening for new orders...");

// 2. Listen for new Order documents
db.collection('orders').onSnapshot(snapshot => {
  snapshot.docChanges().forEach(async (change) => {
    if (change.type === 'added') {
      const order = change.doc.data();
      const orderId = change.doc.id;
      
      // Skip old orders based on timestamp logic if needed, 
      // but for "newly added" in this run session, it's fine.
      // Better: Check if created within last 1 minute or check a 'notificationSent' flag.
      
      const createdAt = order.createdAt ? order.createdAt.toDate() : new Date();
      const now = new Date();
      const timeDiff = (now - createdAt) / 1000; // seconds

      // If order is older than 60 seconds associated with this boot, ignore (optional safety)
      // For now, we process all 'added' events that the listener catches live.
      
      console.log(`📦 New Order Detected: ${orderId} for Farmer: ${order.farmerId}`);

      try {
        // 3. Get Farmer's FCM Token
        const farmerDoc = await db.collection('users').doc(order.farmerId).get();
        if (!farmerDoc.exists) {
            console.log("⚠️ Farmer user document not found.");
            return;
        }

        const farmerData = farmerDoc.data();
        const fcmToken = farmerData.fcmToken;

        if (!fcmToken) {
          console.log(`⚠️ No FCM Token found for farmer ${order.farmerId}`);
          return;
        }

        // 4. Send Push Notification
        const message = {
          token: fcmToken,
          notification: {
            title: 'New Order Received! 🚜',
            body: `You have a new order from ${order.buyerName} for ₹${order.totalAmount}.`,
          },
          data: {
            type: 'order',
            orderId: orderId,
          }
        };

        const response = await messaging.send(message);
        console.log(`✅ Notification sent successfully: ${response}`);

      } catch (error) {
        console.error('❌ Error sending notification:', error);
      }
    }
  });
}, (error) => {
    console.error("❌ Error in snapshot listener:", error);
});
