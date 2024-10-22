import requests
import random
from datetime import datetime, timedelta
import string
import secrets

class Users():

    def get_users_via_api(self):
      
        response = requests.get("https://jsonplaceholder.typicode.com/users", verify=False)

        users = response.json()
        for user in users:
            random_days = random.randint(0, 365 * 50)
            random_date = datetime(1970, 1, 1) + timedelta(days=random_days)
            user['birthday'] = random_date.strftime('%m/%d/%Y') 
          
            user['address']['state'] = self.get_random_word()
          
            user['password'] = self.generate_password()
        
        return users
    
    def get_random_word(self):
        response = requests.get("https://random-word-api.herokuapp.com/word", verify=False)
        return response.json()[0].title()

    def generate_password(self):
        alphabet = string.ascii_letters + string.digits
        return ''.join(secrets.choice(alphabet) for i in range(20))
