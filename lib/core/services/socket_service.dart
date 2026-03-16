import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/api_constants.dart';

class SocketService {
  late io.Socket socket;

  void init() {
    socket = io.io(ApiConstants.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
  }

  void connect() {
    socket.connect();
    socket.onConnect((_) => print('Connected to socket'));
    socket.onDisconnect((_) => print('Disconnected from socket'));
  }

  void disconnect() {
    socket.disconnect();
  }

  void subscribeToAuction(String auctionId) {
    socket.emit('subscribe', {'auctionId': auctionId});
  }

  void onNewBid(Function(dynamic) callback) {
    socket.on('new_bid', (data) => callback(data));
  }

  void onAuctionEnded(Function(dynamic) callback) {
    socket.on('auction_ended', (data) => callback(data));
  }
}
