// Conceptual code for your ingester service

const buffer = [];
const MAX_BUFFER_SIZE = 1000;
const FLUSH_INTERVAL_MS = 10000;

// Subscribe to your decoded MQTT topic
// mqttClient.on('message', (topic, message) => {
//     const sensorData = JSON.parse(message);
//
//     // Transform the JSON payload into the ClickHouse row format
//     const row = {
//         timestamp: new Date(sensorData.timestamp * 1000),
//         device_id: sensorData.device_id,
//         reading_type: sensorData.reading_type,
//         value: sensorData.value,
//         latitude: sensorData.latitude,
//         longitude: sensorData.longitude,
//         geo_country: sensorData.geo_country,
//         // geo_h3_res8 would be calculated here
//         // ... and all other relevant fields
//     };
//
//     buffer.push(row);
//
//     if (buffer.length >= MAX_BUFFER_SIZE) {
//         flushBuffer();
//     }
// });

// Flush the buffer periodically
// setInterval(flushBuffer, FLUSH_INTERVAL_MS);

async function flushBuffer() {
    if (buffer.length === 0) return;

    // Use your ClickHouse client to insert the buffered rows
    // await clickhouse.insert({
    //     table: 'wesense.sensors_raw',
    //     values: buffer,
    //     format: 'JSONEachRow'
    // });

    buffer.length = 0; // Clear the buffer
    console.log(`Flushed ${buffer.length} records to ClickHouse.`);
}
