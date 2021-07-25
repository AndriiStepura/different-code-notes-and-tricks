# Docker logs analysis

```bash
docker logs container-name
```
will show you logs from docker containter(s), to analyse it for error logs or any type of records by RegEx rules we can use this approach:

**I part** - Bash script to store code in text file  
**II part** - Go tests to verify logs for expectations  
**III part** - Changes in pipeline file  

Rename all "container_name_1", "container_name_2", "container_name_3" for your container names.

---

## I part - Bash script to store code in text file  

save_logs.sh
```bash
#!/bin/bash

# Export logs from containers to files
echo "=== START export docker logs from containers to files ==="

echo "container_name_1 logs export"
docker logs container_name_1 >& $(dirname $0)/component_tests_container_name_1.log 2>&1

echo "container_name_2 logs export"
docker logs container_name_2 >& $(dirname $0)/component_tests_container_name_2.log 2>&1

echo "=== Components logs exported from docker logs to files ==="
```


---
## II part - Go tests to verify logs for expectations  

logtest.go
```go
//+build component

package logtest

import (
   "github.com/stretchr/testify/assert"
   "io/ioutil"
   "regexp"
   "testing"
)

const (
   // File names
   container_name_1FileName = "component_tests_container_name_1.log"
   container_name_2FileName = "component_tests_container_name_2.log"   

   // RegExp patterns
   anyCallerIDPattern   = ".*caller-id=.*"
   emptyCallerIDPattern = ".*caller-id= .*"
   container_name_1CallerIDPattern   = ".*caller-id=prh-container_name_1-service.*"
   kafkaEventIDPattern  = ".*event-id=KAFKA.*"
)

// Helper to read file content
func readFileHelper(t *testing.T, fileName string) string {
   fileContent, fileReadErr := ioutil.ReadFile(fileName)
   assert.NoError(t, fileReadErr)
   return string(fileContent)
}

// Helper to find by RegExp all match
func findAllMatchByRegExp(text string, regExPattern string) [][]string {
   var re = regexp.MustCompile(regExPattern)
   matches := re.FindAllStringSubmatch(text, -1)
   return matches
}

// Helper to convert Submatch to strings array
func submatchToStringArray(matches [][]string) []string {
   var stringsArray []string
   for _, line := range matches {
      for _, match := range line {
         stringsArray = append(stringsArray, match)
      }
   }
   return stringsArray
}

// Helper to get string array with lines of file content by RegExp
func findAllMatchInFileByRegExp(t *testing.T, fileName string, regExpPattern string) []string {
   fileContent := readFileHelper(t, fileName)
   matchedContent := findAllMatchByRegExp(fileContent, regExpPattern)
   matchesAsArray := submatchToStringArray(matchedContent)
   return matchesAsArray
}

// Helper to filter strings by RegExp from strings array
func findAllMatchesInStringsArrayByRegExp(stringArray []string, regExpPattern string) []string {
   var matchedStrings []string
   for _, stringItem := range stringArray {
      result, _ := regexp.MatchString(regExpPattern, stringItem)
      if result {
         matchedStrings = append(matchedStrings, stringItem)
      }
   }
   return matchedStrings
}

// container_name_1 logs tests
func TestNoEmptyCallerIDIn_container_name_1_Logs(t *testing.T) {
   logsWithEmptyCallerID := findAllMatchInFileByRegExp(t, container_name_1FileName, emptyCallerIDPattern)
   assert.Equal(t, 0, len(logsWithEmptyCallerID))
}

func TestAllCallerIDIn_container_name_1_LogsAre_STRINGVALUE(t *testing.T) {
   logsWithAnyCallerID := findAllMatchInFileByRegExp(t, container_name_1FileName, anyCallerIDPattern)
   logsWithExpectedCallerID := findAllMatchInFileByRegExp(t, container_name_1FileName, pcsCallerIDPattern)
   assert.Equal(t, len(logsWithAnyCallerID), (len(logsWithExpectedCallerID)))
}

// container_name_2 logs tests
func TestNoEmptyCallerIDIn_container_name_2_Logs(t *testing.T) {
   container_name_2LogsWithEmptyCallerID := findAllMatchInFileByRegExp(t, container_name_2FileName, emptyCallerIDPattern)
   // We know that in one of middleware clients logs KAFKA event records with empty caller-id, so let's ignore them to pass pipeline
   container_name_2LogsWithEmptyCallerIDAndKafka := findAllMatchesInStringsArrayByRegExp(container_name_2LogsWithEmptyCallerID, kafkaEventIDPattern)
   assert.Equal(t, 0, len(container_name_2LogsWithEmptyCallerID)-len(container_name_2LogsWithEmptyCallerIDAndKafka))
}

func TestAllCallerIDIn_container_name_2_LogsAreAsExpected(t *testing.T) {
   container_name_2LogsWithAnyCallerID := findAllMatchInFileByRegExp(t, container_name_2FileName, anyCallerIDPattern)
   container_name_2LogsWithPCSCallerID := findAllMatchInFileByRegExp(t, container_name_2FileName, container_name_1CallerIDPattern)
   // We know that in container_name_1 logs KAFKA event records with empty caller-id, so let's ignore them to pass pipeline
   container_name_2LogsWithEmptyCallerID := findAllMatchInFileByRegExp(t, container_name_2FileName, emptyCallerIDPattern)
   container_name_2LogsWithEmptyCallerIDAndKafka := findAllMatchesInStringsArrayByRegExp(container_name_2LogsWithEmptyCallerID, kafkaEventIDPattern)
   assert.Equal(t, len(container_name_2LogsWithEmptyCallerID), len(container_name_2LogsWithEmptyCallerIDAndKafka))
   assert.Equal(t, len(container_name_2LogsWithAnyCallerID), (len(container_name_2LogsWithPCSCallerID)+len(container_name_2LogsWithEmptyCallerIDAndKafka)))
}
```

---

## III part - Changes in pipeline file  

Update gitlab-ci.yml with this lines at the end of your test job.
```bash
# Run tests of component tests logs
- sh testing/logtest/save_logs.sh
- docker exec -i runner bash -c "cd /go/src/testing/logtest && go test -v -tags=component"
```