class ResponseResult{
    final String error;
    final String message;
    final String caused;
    final int id;

  ResponseResult(this.id,this.error, this.message, this.caused);

  ResponseResult.fromJson(Map<String,dynamic> data,):id=data['id'],error = data['error'],message=data['message'],caused=data['caused'];

}