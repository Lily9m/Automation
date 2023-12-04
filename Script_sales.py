import pyodbc
import pandas as pd

# Establish a connection to the database
driver = os.getenv('DB_DRIVER')
server = os.getenv('DB_SERVER')
database = os.getenv('DB_DATABASE')
username = os.getenv('DB_USERNAME')
password = os.getenv('DB_PASSWORD')

# Establish a connection to the database
conn = pyodbc.connect(f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password}')

# Create a cursor from the connection
cur = conn.cursor()

# Load data from CSV file into a pandas DataFrame
df = pd.read_csv(r'C:\Users\User\Documents\Automation\sales_data.csv')

# Write the data from DataFrame to the database
for index, row in df.iterrows():
    cur.execute("""
    IF NOT EXISTS (SELECT 1 FROM SalesABC.dbo.sales_data WHERE ProductID = ?)
    BEGIN
        INSERT INTO SalesABC.dbo.sales_data (ProductID, ProductName, Price, Quantity, Total, Discount, Tax, Shipping, Profit, StaffName, OrderDate, InsertUpdateDateTime)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())
    END
    """, row['ProductID'], row['ProductID'], row['ProductName'], row['Price'], row['Quantity'], row['Total'], row['Discount'], row['Tax'], row['Shipping'], row['Profit'], row['StaffName'], row['OrderDate'])

# Commit the transaction
conn.commit()

# Close the cursor and connection
cur.close()
conn.close()
