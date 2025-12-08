import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

export interface HttpRequestOptions {
  method: string;
  url: string;
  headers?: Record<string, string>;
  body?: string;
}

export interface HttpResponse {
  statusCode: number;
  headers: Record<string, string>;
  body: string;
}

export class HttpUtils {
  
  static async sendRequest(options: HttpRequestOptions): Promise<HttpResponse> {
    return new Promise((resolve, reject) => {
      let httpRequest = http.createHttp();
      
      let requestMethod: http.RequestMethod;
      switch (options.method.toUpperCase()) {
        case 'GET':
          requestMethod = http.RequestMethod.GET;
          break;
        case 'POST':
          requestMethod = http.RequestMethod.POST;
          break;
        case 'PUT':
          requestMethod = http.RequestMethod.PUT;
          break;
        case 'DELETE':
          requestMethod = http.RequestMethod.DELETE;
          break;
        case 'PATCH':
          // PATCH is not supported in HarmonyOS RequestMethod, use POST instead
          requestMethod = http.RequestMethod.POST;
          break;
        default:
          requestMethod = http.RequestMethod.GET;
      }
      
      let headers: Record<string, string> = options.headers || {};
      let httpRequestOptions: http.HttpRequestOptions = {
        method: requestMethod,
        header: headers,
        extraData: options.body || '',
        connectTimeout: 30000,
        readTimeout: 30000
      };
      
      hilog.info(0x0000, 'HttpUtils', `Sending ${options.method} request to ${options.url}`);
      
      httpRequest.request(options.url, httpRequestOptions, (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          // Convert headers to Record<string, string>
          let responseHeaders: Record<string, string> = {};
          if (data.header) {
            let headerObj = data.header as Record<string, string | string[]>;
            let keys = Object.keys(headerObj);
            for (let i = 0; i < keys.length; i++) {
              let key = keys[i];
              let value = headerObj[key];
              if (Array.isArray(value)) {
                responseHeaders[key] = value.join(', ');
              } else {
                responseHeaders[key] = value;
              }
            }
          }
          
          let responseBody: string;
          if (typeof data.result === 'string') {
            responseBody = data.result;
          } else {
            responseBody = JSON.stringify(data.result);
          }
          
          hilog.info(0x0000, 'HttpUtils', `Response status: ${data.responseCode}`);
          
          resolve({
            statusCode: data.responseCode,
            headers: responseHeaders,
            body: responseBody
          });
        } else {
          hilog.error(0x0000, 'HttpUtils', `Request failed: ${err.message}`);
          reject(new Error(`HTTP request failed: ${err.message}`));
        }
        
        httpRequest.destroy();
      });
    });
  }
}
