const express = require('express');
const app = express();
const port = process.env.PORT || 3001;
const version = '2.0.0';

app.set('view engine', 'ejs');
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Less efficient prime number calculation function
function isPrime(num) {
  if (num <= 1) return false;
  for (let i = 2; i < num; i++) {
    if (num % i === 0) {
      return false;
    }
  }
  return true;
}

function findPrimes(max) {
  const primes = [];
  for (let i = 2; i <= max; i++) {
    if (isPrime(i)) {
      primes.push(i);
    }
  }
  return primes;
}

app.get('/', (req, res) => {
  res.render('index', { version: version, number: null, primes: null, time: null });
});

app.post('/calculate', (req, res) => {
  const number = parseInt(req.body.number, 10);
  if (isNaN(number) || number < 0) {
    return res.render('index', { version: version, number: null, primes: null, time: null, error: 'Please enter a valid non-negative number.' });
  }
  const startTime = Date.now();
  const primes = findPrimes(number);
  const endTime = Date.now();
  const timeTaken = (endTime - startTime) / 1000; // in seconds
  res.render('index', { version: version, number: number, primes: primes, time: timeTaken, error: null });
});

app.listen(port, () => {
  console.log(`App version ${version} listening at http://localhost:${port}`);
});
