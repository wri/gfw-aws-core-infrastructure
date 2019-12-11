const aws = require('aws-sdk');
const s3 = new aws.S3({ region: 'us-east-1' });

const s3Params = {
  Bucket: 'gfw-tiles',
  Key: 'latest',
};
const TTL = 5000; // TTL of 5 seconds


async function fetchRedirectionsFromS3() {
  const response = await s3.getObject(s3Params).promise();
  return JSON.parse(response.Body.toString('utf-8')).map(
    ({ name, latest_version }) => ({
      name: new RegExp(name),
      latest_version,
    })
  );
}


let redirections;
function fetchRedirections() {
  if (!redirections) {
    redirections = fetchRedirectionsFromS3();

    setTimeout(() => {
      redirections = undefined;
    }, TTL);
  }

  return redirections;
}


exports.handler = async event => {
  var request = event.Records[0].cf.request;
  console.log("REQUEST URI:" + request.uri);
  var elements = request.uri.split('/');
  const dataset = elements[1];
  console.log("DATASET: " + dataset);

  try {
    const redirects = await fetchRedirections();

    for (const { name, latest_version } of redirects) {
      if (name.test(dataset)) {

        console.log("LATEST VERSION: " + latest_version);
        elements.forEach((element, index) => {
            if (element === "latest") {
                elements[index] = latest_version;
            }
            else { elements[index] = element }
        });

        request.uri = elements.join('/');
        //let destination = elements.join('/');

        return request;
        //{
        //  status: '302',
        //  statusDescription: 'Found',
        //  headers: {
        //    location: [{ value: destination }],
        //  },
        //};
      }
    }

    return request;

  } catch (_error) {
    return request;
  }
};
