# go notes Test Table - ginkgo DescribeTable & Entry

Go tests in Ginkgo with table driven testing

```go
movedHotelsTestImpl := func(hotelIDInRequest string, expectedHotelIDInResponse string, expectedResponseDataFile string) {
   // Arrange
   // Call to helper function to get data from JSON file and organize basic test data validation
   expectedResponseData := getJSONFileData(
      fmt.Sprintf("testdata/expectedresponses/GetHotelById/%v", expectedResponseDataFile),
      "hotel_id",
      1)
   // Unmarshal data from JSON to map with our structure from proto to create expected response
   var expectedResponse hotelcontent.HotelByIdResponse
   json.Unmarshal([]byte(expectedResponseData), &expectedResponse)

   // Act
   res, err := hotelContentSearchClient.GetHotelById(context.Background(), &hotelcontent.HotelByIdRequest{
      HotelId:              hotelIDInRequest,
      SitePrivateRateSetId: sitePrivateRateSetId2,
   })

   // Assert
   // For positive test scenarios validate that no response error occurred
   By("an error hasn't occurred")
   Expect(err).ToNot(HaveOccurred(), "an unexpected error has occurred")
   By("a response is not empty")
   Expect(res).ToNot(BeNil(), "response is nil")

   // Main assertions for most important response data validation
   By("a response contains Hotel data")
   Expect(res.GetHotel()).ToNot(BeNil(), "response is nil but HotelID exists in ES")
   By(fmt.Sprintf("a HotelID data in response Hotel.Property.HotelId for requested - '%v' is the HotelID of moved to hotel - '%v'", hotelIDInRequest, expectedHotelIDInResponse))
   Expect(res.GetHotel().GetProperty().GetHotelId()).Should(Equal(expectedHotelIDInResponse), failedMatchingDataAssertErrorTextDescription)
   By("a response Hotel Property data is the same as expected")
   Expect(res.GetHotel().GetPrivateRate().GetPrh().GetSeasonalRates()).To(Equal(expectedResponse.Hotel.PrivateRate.Prh.SeasonalRates), failedMatchingDataAssertErrorTextDescription)
   Expect(res.GetHotel().GetProperty()).To(Equal(expectedResponse.Hotel.Property), failedMatchingDataAssertErrorTextDescription)
   By("a response Hotel.PrivateRate data is the same as expected")
   Expect(res.GetHotel().GetPrivateRate()).To(Equal(expectedResponse.Hotel.PrivateRate), failedMatchingDataAssertErrorTextDescription)
   By(fmt.Sprintf("a response Hotel.Distance is the same as expected - '%v'", expectedResponse.Hotel.Distance))
   Expect(res.GetHotel().GetDistance()).To(Equal(expectedResponse.Hotel.Distance), failedMatchingDataAssertErrorTextDescription)
}

DescribeTable("[TC-PR-2] GetHotelById response for request with moved hotel returns final hotel with PR data for all moved and final IDs", movedHotelsTestImpl,
   Entry("Request with the first ID of moved once hotel", movedOnceFromHotelIdWithPrivateRateData, movedOnceToHotelIdWithPrivateRateData, "TC2-PR-moved-once-hotel"),
   Entry("Request with the last ID of moved once hotel", movedOnceToHotelIdWithPrivateRateData, movedOnceToHotelIdWithPrivateRateData, "TC2-PR-moved-once-hotel"),
   Entry("Request with the first ID of moved five times hotel", movedFiveTimesFromHotelId1, movedFiveTimesToHotelIdWithPrivateRateData, "TC2-PR-moved-five-times-hotel"),
   Entry("Request with the second ID of moved five times hotel", movedFiveTimesFromHotelId2, movedFiveTimesToHotelIdWithPrivateRateData, "TC2-PR-moved-five-times-hotel"),
   Entry("Request with the third ID of moved five times hotel", movedFiveTimesFromHotelId3, movedFiveTimesToHotelIdWithPrivateRateData, "TC2-PR-moved-five-times-hotel"),
   Entry("Request with the fourth ID of moved five times hotel", movedFiveTimesFromHotelId4, movedFiveTimesToHotelIdWithPrivateRateData, "TC2-PR-moved-five-times-hotel"),
   Entry("Request with the last of moved five times hotel", movedFiveTimesToHotelIdWithPrivateRateData, movedFiveTimesToHotelIdWithPrivateRateData, "TC2-PR-moved-five-times-hotel"),
)
or less readable and with code inside and obsolete printer outside if we want to put variables as part of TC description:
movedHotelTestSteps := func(testCaseDescription string) func(string, string, string) string {
   return func(hotelIDReq, hotelIDRes, responseDataFile string) string {
      return fmt.Sprintf("Test case - '%s' \nwith requested ID - '%s' returns in response data from moved to HotelID - '%s'", testCaseDescription, hotelIDReq, hotelIDRes)
   }
}

DescribeTable("[TC-PR-2] GetHotelById response for request with moved hotel returns final hotel with PR data for all moved and final IDs",
   func(hotelIDInRequest string, expectedHotelIDInResponse string, expectedResponseDataFile string) {
      // Arrange
      // Call to helper function to get data from JSON file and organize basic test data validation
      expectedResponseData := getJSONFileData(
         fmt.Sprintf("testdata/expectedresponses/GetHotelById/%v", expectedResponseDataFile),
         "hotel_id",
         1)
      // Unmarshal data from JSON to map with our structure from proto to create expected response
      var expectedResponse hotelcontent.HotelByIdResponse
      json.Unmarshal([]byte(expectedResponseData), &expectedResponse)

      // Act
      res, err := hotelContentSearchClient.GetHotelById(context.Background(), &hotelcontent.HotelByIdRequest{
         HotelId:              hotelIDInRequest,
         SitePrivateRateSetId: sitePrivateRateSetId2,
      })

      // Assert
      // For positive test scenarios validate that no response error occurred
      By("an error hasn't occurred")
      Expect(err).ToNot(HaveOccurred(), "an unexpected error has occurred")
      By("a response is not empty")
      Expect(res).ToNot(BeNil(), "response is nil")

      // Main assertions for most important response data validation
      By("a response contains Hotel data")
      Expect(res.GetHotel()).ToNot(BeNil(), "response is nil but HotelID exists in ES")
      By(fmt.Sprintf("a HotelID data in response Hotel.Property.HotelId for requested - '%v' is the HotelID of moved to hotel - '%v'", hotelIDInRequest, expectedHotelIDInResponse))
      Expect(res.GetHotel().GetProperty().GetHotelId()).Should(Equal(expectedHotelIDInResponse), failedMatchingDataAssertErrorTextDescription)
      By("a response Hotel Property data is the same as expected")
      Expect(res.GetHotel().GetPrivateRate().GetPrh().GetSeasonalRates()).To(Equal(expectedResponse.Hotel.PrivateRate.Prh.SeasonalRates), failedMatchingDataAssertErrorTextDescription)
      Expect(res.GetHotel().GetProperty()).To(Equal(expectedResponse.Hotel.Property), failedMatchingDataAssertErrorTextDescription)
      By("a response Hotel.PrivateRate data is the same as expected")
      Expect(res.GetHotel().GetPrivateRate()).To(Equal(expectedResponse.Hotel.PrivateRate), failedMatchingDataAssertErrorTextDescription)
      By(fmt.Sprintf("a response Hotel.Distance is the same as expected - '%v'", expectedResponse.Hotel.Distance))
      Expect(res.GetHotel().GetDistance()).To(Equal(expectedResponse.Hotel.Distance), failedMatchingDataAssertErrorTextDescription)
   },
   Entry(movedHotelTestSteps("Request with the first ID of moved once hotel"), movedOnceFromHotelIdWithPrivateRateData, movedOnceToHotelIdWithPrivateRateData, "TC2-PR-moved-once-hotel"),
   Entry(movedHotelTestSteps("Request with the last ID of moved once hotel"), movedOnceToHotelIdWithPrivateRateData, movedOnceToHotelIdWithPrivateRateData, "TC2-PR-moved-once-hotel"),
   Entry(movedHotelTestSteps("Request with the first ID of moved five times hotel"), movedFiveTimesFromHotelId1, movedFiveTimesToHotelIdWithPrivateRateData, "TC2-PR-moved-five-times-hotel"),
   Entry(movedHotelTestSteps("Request with the second ID of moved five times hotel"), movedFiveTimesFromHotelId2, movedFiveTimesToHotelIdWithPrivateRateData, "TC2-PR-moved-five-times-hotel"),
   Entry(movedHotelTestSteps("Request with the third ID of moved five times hotel"), movedFiveTimesFromHotelId3, movedFiveTimesToHotelIdWithPrivateRateData, "TC2-PR-moved-five-times-hotel"),
   Entry(movedHotelTestSteps("Request with the fourth ID of moved five times hotel"), movedFiveTimesFromHotelId4, movedFiveTimesToHotelIdWithPrivateRateData, "TC2-PR-moved-five-times-hotel"),
   Entry(movedHotelTestSteps("Request with the last of moved five times hotel"), movedFiveTimesToHotelIdWithPrivateRateData, movedFiveTimesToHotelIdWithPrivateRateData, "TC2-PR-moved-five-times-hotel"),
)
```