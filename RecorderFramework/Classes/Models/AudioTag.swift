//
//  AudioTag.swift
//  Pods
//
//  Created by Stefanita Oaca on 04/11/2018.
//

public enum TagType : String {
    case note = "note"
    case todo = "todo"
    case date = "date"
    case alert = "alert"
    case images = "images"
    case audio = "audio"
    case video = "video"
    case tags = "tags"
    case beforeAfter = "beforeAfter"
    case panorama = "panorama"
    case productViewer = "productViewer"
    case pageFlip = "pageFlip"
    case location = "location"
    case phoneNumber = "phoneNumber"
    case socialMedia = "socialMedia"
    case imageURL = "imageURL"
    case htmlEmbed = "htmlEmbed"
    public static let allValues = [note, todo, date, alert, images, audio, video, tags, beforeAfter, panorama, productViewer, pageFlip, location, phoneNumber, socialMedia, imageURL, htmlEmbed]
}

public class AudioTag: NSObject {
    public var type:TagType = TagType.note
    public var timeStamp:TimeInterval!
    public var duration:TimeInterval!
    public var arg:AnyObject!
    public var arg2:AnyObject!
}
