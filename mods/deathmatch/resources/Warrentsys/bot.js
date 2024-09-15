const mysql = require('mysql2');
const axios = require('axios');
const cron = require('node-cron');

// Database connection configuration
const dbConfig = {
    host: 'localhost',         // Replace with your database host
    user: 'root',         // Replace with your database username
    password: '', // Replace with your database password
    database: 'mta'  // Replace with your database name
};

// Discord webhook URL
const webhookUrl = 'link';  // Replace with your Discord webhook URL

function formatDate(date) {
    if (!date) return 'N/A';
    const options = { year: 'numeric', month: '2-digit', day: '2-digit' };
    return new Date(date).toLocaleDateString('en-GB', options).split('/').reverse().join('-');
}

// Function to fetch data from the database
async function fetchWarrantData() {
    const connection = mysql.createConnection(dbConfig);

    return new Promise((resolve, reject) => {
        connection.query(`
            SELECT 
                id,
                suspectName,
                reason,
                vehiclePlate,
                officerName,
                start_date,
                end_date
            FROM 
                warrants
            WHERE
                start_date = CURDATE()
        `, (error, results) => {
            if (error) {
                reject(error);
            } else {
                resolve(results);
            }
            connection.end();
        });
    });
}

// Function to send a message to Discord
async function sendDiscordMessage(data) {
    const message = `
    **Warrant Information**
    
    **Start Date:** ${formatDate(data.start_date)}
    **End Date:** ${formatDate(data.end_date)}
    **Criminal Name:** ${data.suspectName || 'N/A'}
    **Reason:** ${data.reason || 'N/A'}
    **The Police Officer Issuing the Warrant:** ${data.officerName || 'N/A'}
    `;
    
    try {
        const response = await axios.post(webhookUrl, {
            content: message
        }, {
            headers: {
                'Content-Type': 'application/json'
            }
        });
        if (response.status === 204) {
            console.log('Message sent successfully.');
        } else {
            console.log(`Failed to send message. Status code: ${response.status}`);
        }
    } catch (error) {
        console.error('Error sending message:', error);
    }
}

// Function to fetch data and send it to Discord
async function fetchAndNotify() {
    try {
        const dataRows = await fetchWarrantData();
        for (const data of dataRows) {
            await sendDiscordMessage(data);
        }
    } catch (error) {
        console.error('Error:', error);
    }
}

// Schedule the script to run daily at midnight (server's local time)
cron.schedule('0 0 * * *', fetchAndNotify);

// Initial run
fetchAndNotify();